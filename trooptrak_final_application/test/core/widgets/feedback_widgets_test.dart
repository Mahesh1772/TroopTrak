import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/state/view_state.dart';
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

  testWidgets('EmptyState shows image and message', (tester) async {
    await tester.pumpThemed(
      const EmptyState(message: 'NO CONDUCTS FOR TODAY!'),
      mode: themeModes.currentValue!,
    );
    expect(find.text('NO CONDUCTS FOR TODAY!'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  }, variant: themeModes);

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

  testWidgets('StreamView follows Either events from a stream', (tester) async {
    final controller = StreamController<Either<Failure, int>>();
    addTearDown(controller.close);
    await tester.pumpThemed(StreamView<int>(
      stream: controller.stream,
      builder: (_, v) => Text('value $v'),
    ));
    expect(find.byType(LoadingView), findsOneWidget);

    controller.add(const Right(3));
    await tester.pump();
    expect(find.text('value 3'), findsOneWidget);

    controller.add(const Left(NotFoundFailure('missing')));
    await tester.pump();
    expect(find.text('missing'), findsOneWidget);
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
