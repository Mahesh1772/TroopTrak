import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/state/view_state.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/app_snackbar.dart';
import 'package:trooptrak_final_application/core/widgets/confirm_dialog.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/hero_dialog_route.dart';
import 'package:trooptrak_final_application/core/widgets/state_view.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('LoadingView shows a spinner', (tester) async {
    await tester.pumpThemed(const LoadingView(),
        mode: themeModes.currentValue!);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }, variant: themeModes);

  group('EmptyState', () {
    testWidgets('shows a 40 px muted icon over a bold message', (tester) async {
      final mode = themeModes.currentValue!;
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      await tester.pumpThemed(
        const EmptyState(
          message: 'NO CONDUCTS FOR TODAY!',
          icon: Icons.event_busy_rounded,
        ),
        mode: mode,
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.event_busy_rounded));
      final message =
          tester.widget<Text>(find.text('NO CONDUCTS FOR TODAY!')).style!;

      expect(icon.size, 40);
      expect(icon.color, palette.mutedText);
      expect([message.fontSize, message.fontWeight], [17, FontWeight.w700]);
      expect(message.color, palette.onCard);
      expect(message.fontFamily, startsWith('Barlow'));
      expect(find.byType(Image), findsNothing);
      expect(tester.getCenter(find.text('NO CONDUCTS FOR TODAY!')).dx, 195);
    }, variant: themeModes);

    testWidgets('without an icon or subtitle it is only the message',
        (tester) async {
      await tester.pumpThemed(const EmptyState(message: 'Nothing here yet'));
      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('a subtitle sits under the message in secondary text',
        (tester) async {
      await tester.pumpThemed(const EmptyState(
        message: 'No duties',
        subtitle: 'Add one with the plus button',
        icon: Icons.shield_outlined,
      ));
      final message = tester.getRect(find.text('No duties'));
      final subtitle =
          tester.getRect(find.text('Add one with the plus button'));
      final style =
          tester.widget<Text>(find.text('Add one with the plus button')).style!;

      expect(subtitle.top, greaterThanOrEqualTo(message.bottom + 4));
      expect(style.color, AppPalette.dark.secondaryText);
      expect(style.fontSize, 16);
    });

    testWidgets('keeps 36 px above and below', (tester) async {
      await tester.pumpThemed(
          const SingleChildScrollView(child: EmptyState(message: 'Nothing')));
      final box = tester.getRect(find.byType(EmptyState));
      final text = tester.getRect(find.text('Nothing'));

      expect(text.top - box.top, 36);
      expect(box.bottom - text.bottom, 36);
    });

    testWidgets('a long message wraps inside 24 px side padding',
        (tester) async {
      await tester.pumpThemed(SingleChildScrollView(
          child: EmptyState(message: List.filled(40, 'Nothing').join(' '))));
      final text = tester.getRect(find.byType(Text));

      expect(text.width, lessThanOrEqualTo(390 - 48));
      expect(text.left, greaterThanOrEqualTo(24));
    });
  });

  testWidgets('ErrorView shows message and retry', (tester) async {
    var retries = 0;
    await tester.pumpThemed(
      ErrorView(message: 'Network down', onRetry: () => retries++),
      mode: themeModes.currentValue!,
    );
    expect(find.text('Network down'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  }, variant: themeModes);

  group('ConfirmDialog', () {
    Future<Future<bool>> open(WidgetTester tester) async {
      late Future<bool> result;
      await tester.pumpThemed(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => result = ConfirmDialog.show(
                context,
                title: 'Delete soldier?',
                message: 'This cannot be undone.',
                confirmLabel: 'Delete',
                destructive: true,
              ),
              child: const Text('open'),
            ),
          ),
          mode: themeModes.currentValue ?? ThemeMode.dark);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('returns true on confirm', (tester) async {
      final result = await open(tester);
      expect(find.text('Delete soldier?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
    }, variant: themeModes);

    testWidgets('returns false on cancel', (tester) async {
      final result = await open(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });
  });

  testWidgets('AppSnackbar shows success and error messages', (tester) async {
    await tester.pumpThemed(
        Builder(
          builder: (context) => Column(children: [
            TextButton(
                onPressed: () => AppSnackbar.success(context, 'Saved'),
                child: const Text('ok')),
            TextButton(
                onPressed: () => AppSnackbar.error(context, 'Failed'),
                child: const Text('bad')),
          ]),
        ),
        mode: themeModes.currentValue!);

    await tester.tap(find.text('ok'));
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.text('bad'));
    await tester.pumpAndSettle();
    expect(find.text('Failed'), findsOneWidget);
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);
  }, variant: themeModes);

  group('StateView', () {
    Widget view(ViewState<List<int>> state) => StateView<List<int>>(
          state: state,
          isEmpty: (d) => d.isEmpty,
          empty: const Text('empty'),
          builder: (_, data) => Text('items ${data.length}'),
        );

    testWidgets('renders loading, error, empty and data', (tester) async {
      await tester.pumpThemed(view(const ViewLoading()),
          mode: themeModes.currentValue!);
      expect(find.byType(LoadingView), findsOneWidget);

      await tester.pumpThemed(view(const ViewError(ServerFailure('boom'))),
          mode: themeModes.currentValue!);
      expect(find.text('boom'), findsOneWidget);

      await tester.pumpThemed(view(const ViewData([])),
          mode: themeModes.currentValue!);
      expect(find.text('empty'), findsOneWidget);

      await tester.pumpThemed(view(const ViewData([1, 2])),
          mode: themeModes.currentValue!);
      expect(find.text('items 2'), findsOneWidget);
    }, variant: themeModes);
  });

  testWidgets('HeroDialogRoute opens a non-opaque dismissible popup',
      (tester) async {
    await tester.pumpThemed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(HeroDialogRoute<void>(
              builder: (_) => const Center(child: Text('popup')),
            )),
            child: const Text('open'),
          ),
        ),
        mode: themeModes.currentValue!);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('popup'), findsOneWidget);
    expect(find.text('open'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('popup'), findsNothing);
  }, variant: themeModes);

  test('CustomRectTween eases between rects', () {
    final tween = CustomRectTween(
      begin: const Rect.fromLTRB(0, 0, 10, 10),
      end: const Rect.fromLTRB(100, 100, 110, 110),
    );
    expect(tween.lerp(0), const Rect.fromLTRB(0, 0, 10, 10));
    expect(tween.lerp(1), const Rect.fromLTRB(100, 100, 110, 110));
    expect(tween.lerp(0.5).left, greaterThan(50));
  });
}
