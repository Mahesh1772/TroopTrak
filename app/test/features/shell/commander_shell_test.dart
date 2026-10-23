import 'package:dartz/dartz.dart' show Right;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/features/shell/presentation/pages/commander_shell.dart';
import 'package:trooptrak_final_application/features/shell/presentation/providers/commander_rank_provider.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockWatchSoldier extends Mock implements WatchSoldier {}

class _Counter extends StatefulWidget {
  const _Counter(this.label);

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => taps++),
        child: Text('${widget.label} $taps'),
      );
}

void main() {
  const tabKeys = ['home', 'nominalRoll', 'conductTracker', 'guardDuty'];
  late List<String> built;

  Future<RouteRecorder> pumpShell(
    WidgetTester tester, {
    ThemeMode mode = ThemeMode.dark,
    String? commanderId = 'Cmd Lim',
  }) async {
    built = [];
    final watchSoldier = _MockWatchSoldier();
    when(() => watchSoldier('Cmd Lim')).thenAnswer((_) => Stream.value(
        Right<Failure, Soldier>(buildSoldier(name: 'Cmd Lim', rank: 'CPT'))));
    WidgetBuilder tab(String label) => (_) {
          built.add(label);
          return _Counter(label);
        };
    final recorder = RouteRecorder();
    await tester.pumpApp(
      CommanderShell(
        home: tab('home'),
        nominalRoll: tab('roll'),
        conductTracker: tab('conducts'),
        guardDuty: tab('duty'),
      ),
      mode: mode,
      observers: [recorder],
      providers: [
        ChangeNotifierProvider(
            create: (_) => CommanderRankProvider(watchSoldier, commanderId)),
      ],
    );
    await tester.pump();
    return recorder;
  }

  Text titleText(WidgetTester tester) => tester.widget<Text>(
      find.descendant(of: find.byType(AppBar), matching: find.byType(Text)));

  String title(WidgetTester tester) => titleText(tester).data!;

  Gradient? pillGradient(WidgetTester tester, String tab) {
    final box = tester.widget<DecoratedBox>(find
        .descendant(
            of: find.byKey(ValueKey('navPill-$tab')),
            matching: find.byType(DecoratedBox))
        .first);
    return (box.decoration as BoxDecoration).gradient;
  }

  RankPlate avatarPlate(WidgetTester tester) =>
      tester.widget<RankPlate>(find.descendant(
          of: find.byKey(const Key('userProfileIcon')),
          matching: find.byType(RankPlate)));

  testWidgets('four tabs in source order; home first', (tester) async {
    await pumpShell(tester, mode: themeModes.currentValue!);
    for (final key in tabKeys) {
      expect(find.byKey(Key(key)), findsOneWidget);
    }
    final xs = [
      for (final key in tabKeys) tester.getCenter(find.byKey(Key(key))).dx,
    ];
    expect(xs, [...xs]..sort());
    expect(title(tester), 'Dashboard');
    expect(find.text('home 0'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('the bar is a themed NavigationBar with four labelled tabs',
      (tester) async {
    final mode = themeModes.currentValue!;
    await pumpShell(tester, mode: mode);
    final bar = find.byType(NavigationBar);
    expect(tester.widget<NavigationBar>(bar).destinations, hasLength(4));
    expect(tester.getSize(bar).height, AppLayout.shellNavBarHeight);
    for (final label in ['Home', 'Nominal Roll', 'Conducts', 'Guard Duty']) {
      expect(find.text(label), findsOneWidget);
    }
    final palette = mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
    final material = tester.widget<Material>(
        find.descendant(of: bar, matching: find.byType(Material)).first);
    expect(material.color, palette.navBar);
  }, variant: themeModes);

  testWidgets('only the active tab has the gradient pill', (tester) async {
    await pumpShell(tester);

    void expectActive(String active) {
      for (final tab in tabKeys) {
        final gradient = pillGradient(tester, tab);
        if (tab == active) {
          expect(
              (gradient! as LinearGradient).colors, AppColors.navPillGradient);
        } else {
          expect(gradient, isNull);
        }
      }
    }

    expectActive('home');
    for (final tab in tabKeys.skip(1)) {
      await tester.tap(find.byKey(Key(tab)));
      await tester.pumpAndSettle();
      expectActive(tab);
    }
  });

  testWidgets('title is 24 w600; the avatar is the commander rank plate',
      (tester) async {
    await pumpShell(tester, mode: themeModes.currentValue!);
    final style = titleText(tester).style!;
    expect([style.fontSize, style.fontWeight], [24, FontWeight.w600]);
    expect(avatarPlate(tester).rank, 'CPT');
    expect(tester.getSize(find.byType(RankPlate)),
        const Size.square(RankPlate.md));
  }, variant: themeModes);

  testWidgets('the avatar opens the profile even without a rank',
      (tester) async {
    final recorder = await pumpShell(tester, commanderId: null);
    expect(avatarPlate(tester).rank, isEmpty);
    await tester.tap(find.byKey(const Key('userProfileIcon')));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.commanderProfile);
  });

  testWidgets('titles follow the tab; tabs build lazily and keep state',
      (tester) async {
    await pumpShell(tester);
    expect(built, ['home']);
    await tester.tap(find.text('home 0'));
    await tester.pump();

    for (final (key, expected) in [
      ('nominalRoll', 'Nominal Roll'),
      ('conductTracker', 'Conduct Tracker'),
      ('guardDuty', 'Guard Duty'),
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(title(tester), expected);
    }
    expect(built.toSet(), {'home', 'roll', 'conducts', 'duty'});

    await tester.tap(find.byKey(const Key('home')));
    await tester.pumpAndSettle();
    expect(title(tester), 'Dashboard');
    expect(find.text('home 1'), findsOneWidget);
  });

  testWidgets('profile icon opens the commander profile route', (tester) async {
    final recorder = await pumpShell(tester);
    await tester.tap(find.byKey(const Key('userProfileIcon')));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.commanderProfile);
  });

  testWidgets('system back does not leave the shell', (tester) async {
    await pumpShell(tester);
    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);
  });
}
