import 'dart:async';

import 'package:trooptrak_final_application/core/services/tick_source.dart';

import 'fake_clock.dart';

/// Ticks only when told to; [tick] also moves [clock] by the period.
class FakeTickSource implements TickSource {
  FakeTickSource(this.clock);

  final FixedClock clock;
  final _controller = StreamController<void>.broadcast(sync: true);
  Duration _period = Duration.zero;

  bool get hasListener => _controller.hasListener;

  @override
  Stream<void> every(Duration period) {
    _period = period;
    return _controller.stream;
  }

  void tick([int times = 1]) {
    for (var i = 0; i < times; i++) {
      clock.advance(_period);
      _controller.add(null);
    }
  }
}
