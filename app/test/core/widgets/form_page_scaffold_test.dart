import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/app_text_field.dart';
import 'package:trooptrak_final_application/core/widgets/form_page_scaffold.dart';
import 'package:trooptrak_final_application/core/widgets/inline_error.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';
import 'package:trooptrak_final_application/core/widgets/sticky_cta_bar.dart';
import 'package:trooptrak_final_application/core/widgets/sticky_cta_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  final cta = find.byKey(const Key('cta'));
  final lastField = find.byKey(const Key('field-29'));

  Future<void> pumpForm(
    WidgetTester tester, {
    String? title,
    String? subtitle,
    int fields = 30,
    ThemeMode mode = ThemeMode.dark,
  }) =>
      tester.pumpApp(
        FormPageScaffold(
          formKey: formKey,
          title: title,
          subtitle: subtitle,
          cta: PrimaryButton(
              label: 'SAVE', key: const Key('cta'), onPressed: () {}),
          children: [
            for (var i = 0; i < fields; i++)
              AppTextField(
                key: Key('field-$i'),
                controller: controller,
                label: 'Label $i:',
                icon: Icons.person_rounded,
                validator: (v) => (v ?? '').isEmpty ? 'Missing $i' : null,
              ),
          ],
        ),
        mode: mode,
      );

  Future<void> scrollToEnd(WidgetTester tester) => tester.dragUntilVisible(
        lastField,
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );

  group('FormPageScaffold', () {
    testWidgets('shows the title bar and subtitle when given', (tester) async {
      await pumpForm(tester, title: 'Add soldier', subtitle: 'Fill it in');
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Add soldier'), findsOneWidget);
      expect(find.text('Fill it in'), findsOneWidget);
    });

    testWidgets('has no app bar without a title', (tester) async {
      await pumpForm(tester);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('the CTA stays put while the fields scroll under it',
        (tester) async {
      await pumpForm(tester, title: 'Add soldier');
      final before = tester.getRect(cta);

      final height = tester.view.physicalSize.height;
      expect(tester.getRect(lastField).top, greaterThan(height));
      await scrollToEnd(tester);
      expect(tester.getRect(lastField).bottom, lessThanOrEqualTo(height));
      expect(tester.getRect(cta), before);
      expect(before.bottom, lessThanOrEqualTo(tester.view.physicalSize.height));
    });

    testWidgets('the last field ends above the CTA', (tester) async {
      await pumpForm(tester);
      await scrollToEnd(tester);
      await tester.pumpAndSettle();
      expect(tester.getRect(lastField).bottom,
          lessThanOrEqualTo(tester.getRect(cta).top));
    });

    testWidgets('the CTA rides above the keyboard', (tester) async {
      await pumpForm(tester);
      final resting = tester.getRect(cta);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      final raised = tester.getRect(cta);
      expect(raised.bottom,
          lessThanOrEqualTo(tester.view.physicalSize.height - 300));
      expect(raised.size, resting.size);
    });

    testWidgets('the bar sits on the page surface in both themes',
        (tester) async {
      await pumpForm(tester, mode: themeModes.currentValue!);
      final bar = tester.widget<ColoredBox>(
        find.ancestor(of: cta, matching: find.byType(ColoredBox)).first,
      );
      expect(bar.color, Theme.of(tester.element(cta)).colorScheme.surface);
    }, variant: themeModes);

    testWidgets('validation runs through the page form', (tester) async {
      await pumpForm(tester, fields: 2);
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Missing 0'), findsOneWidget);
      expect(find.text('Missing 1'), findsOneWidget);
    });
  });

  group('StickyCtaBar', () {
    testWidgets('insets its child 16 px a side, or by horizontal',
        (tester) async {
      await tester.pumpThemed(
        const Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: StickyCtaBar(
              child: SizedBox(key: Key('inner'), height: 50),
            ),
          ),
        ),
      );
      expect(tester.getRect(find.byKey(const Key('inner'))).left, 16);
      expect(tester.getSize(find.byKey(const Key('inner'))).width, 358);

      await tester.pumpThemed(
        const Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: StickyCtaBar(
              horizontal: 24,
              child: SizedBox(key: Key('inner'), height: 50),
            ),
          ),
        ),
      );
      expect(tester.getRect(find.byKey(const Key('inner'))).left, 24);
      expect(tester.getSize(find.byKey(const Key('inner'))).width, 342);
    });
  });

  group('AppTextField', () {
    testWidgets('puts its label 6 px above a 52 px field', (tester) async {
      await pumpForm(tester, fields: 1);
      final label = find.text('Label 0:');
      final input = find.byType(InputDecorator);
      expect(tester.getSize(input).height, 52);
      expect(tester.getRect(input).top - tester.getRect(label).bottom, 6);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('without a label or icon it is a bare field', (tester) async {
      await tester.pumpThemed(AppTextField(controller: controller));
      expect(find.byType(Column), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('hides what is typed when obscured', (tester) async {
      await tester
          .pumpThemed(AppTextField(controller: controller, obscureText: true));
      expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText,
          isTrue);
    });

    testWidgets('the eye shows and hides what was typed', (tester) async {
      bool hidden() =>
          tester.widget<EditableText>(find.byType(EditableText)).obscureText;
      await tester
          .pumpThemed(AppTextField(controller: controller, obscureText: true));
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(hidden(), isFalse);
      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(hidden(), isTrue);
    });

    testWidgets('a plain field has no eye and the eye keeps it 52 high',
        (tester) async {
      await tester.pumpThemed(AppTextField(controller: controller));
      expect(find.byType(IconButton), findsNothing);
      await tester
          .pumpThemed(AppTextField(controller: controller, obscureText: true));
      expect(tester.getSize(find.byType(InputDecorator)).height, 52);
    });

    testWidgets('an error is an inline error in the legible red',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pumpForm(tester, fields: 1, mode: mode);
      expect(find.byType(InlineError), findsNothing);
      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byType(InlineError), matching: find.text('Missing 0')),
          findsOneWidget);
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      expect(tester.widget<Text>(find.text('Missing 0')).style!.color,
          palette.leaveText);
      final field = tester.getRect(find.byType(InputDecorator));
      expect(tester.getRect(find.text('Missing 0')).top,
          greaterThanOrEqualTo(field.top + 52));
      expect(
          tester.getTopLeft(find.byIcon(Icons.error_rounded)).dx - field.left,
          4);
    }, variant: themeModes);
  });

  group('StickyCtaPage', () {
    final pageKey = GlobalKey<FormState>();

    Future<void> pumpPage(
      WidgetTester tester, {
      GlobalKey<FormState>? key,
      int rows = 3,
    }) =>
        tester.pumpApp(
          StickyCtaPage(
            formKey: key,
            cta: PrimaryButton(
                label: 'GO', key: const Key('cta'), onPressed: () {}),
            children: [
              for (var i = 0; i < rows; i++)
                SizedBox(key: Key('row-$i'), height: 120, width: 100),
            ],
          ),
        );

    testWidgets('insets the rows and the button 24 px a side', (tester) async {
      await pumpPage(tester);
      expect(tester.getRect(find.byKey(const Key('row-0'))).left, 24);
      expect(tester.getRect(find.byKey(const Key('row-0'))).top, 20);
      final button = tester.getRect(cta);
      expect(button.left, 24);
      expect(button.right, 366);
    });

    testWidgets('has no app bar and pins the button while the rows scroll',
        (tester) async {
      await pumpPage(tester, rows: 12);
      expect(find.byType(AppBar), findsNothing);
      final before = tester.getRect(cta);
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.getRect(cta), before);
      expect(tester.getRect(find.byKey(const Key('row-0'))).bottom,
          lessThan(before.top));
    });

    testWidgets('the button rides above the keyboard', (tester) async {
      await pumpPage(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.getRect(cta).bottom,
          lessThanOrEqualTo(tester.view.physicalSize.height - 300));
    });

    testWidgets('a form key adds a validating Form, none adds none',
        (tester) async {
      await pumpPage(tester);
      expect(find.byType(Form), findsNothing);
      await pumpPage(tester, key: pageKey);
      expect(find.byType(Form), findsOneWidget);
      expect(pageKey.currentState!.validate(), isTrue);
    });
  });
}
