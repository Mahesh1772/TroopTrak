import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/state/stream_state_notifier.dart';
import 'package:trooptrak_final_application/core/state/view_state.dart';

void main() {
  test('starts loading, then follows data and errors, and cancels on dispose',
      () async {
    final controller = StreamController<Either<Failure, int>>();
    final notifier = StreamStateNotifier<int>(controller.stream);
    var notified = 0;
    notifier.addListener(() => notified++);
    expect(notifier.state, isA<ViewLoading<int>>());

    controller.add(const Right(3));
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state.dataOrNull, 3);

    controller.add(const Left(ServerFailure('down')));
    await Future<void>.delayed(Duration.zero);
    expect((notifier.state as ViewError<int>).failure,
        const ServerFailure('down'));
    expect(notified, 2);

    notifier.dispose();
    expect(controller.hasListener, isFalse);
    await controller.close();
  });
}
