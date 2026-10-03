import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/services/tick_source.dart';
import '../../domain/usecases/men_usecases.dart';

/// The soldier's enlistment QR (R15): publishes a code, counts down
/// [lifetime] from the injected clock and withdraws the code on expiry or
/// dispose, however the dialog was closed.
class EnlistmentQrProvider extends ChangeNotifier {
  EnlistmentQrProvider({
    required String uid,
    required PublishEnlistmentQr publish,
    required ClearEnlistmentQr clear,
    required Clock clock,
    required TickSource ticks,
    this.lifetime = const Duration(minutes: 2),
  })  : _uid = uid,
        _publish = publish,
        _clear = clear,
        _clock = clock,
        _ticks = ticks,
        _remaining = lifetime;

  final String _uid;
  final PublishEnlistmentQr _publish;
  final ClearEnlistmentQr _clear;
  final Clock _clock;
  final TickSource _ticks;
  final Duration lifetime;

  StreamSubscription<void>? _ticking;
  late DateTime _deadline;
  Duration _remaining;
  String? _code;
  String? _error;
  bool _expired = false;
  bool _live = false;
  bool _disposed = false;

  String? get code => _code;
  String? get error => _error;
  bool get expired => _expired;
  Duration get remaining => _remaining;

  /// `mm:ss`, as the source countdown; rounded up so a late tick never skips
  /// a second.
  String get countdown {
    String two(int n) => n.toString().padLeft(2, '0');
    final seconds = (_remaining.inMilliseconds + 999) ~/ 1000;
    return '${two(seconds ~/ 60)}:${two(seconds % 60)}';
  }

  Future<void> start() async {
    _deadline = _clock.now().add(lifetime);
    _ticking = _ticks.every(const Duration(seconds: 1)).listen((_) => _tick());
    _live = true;
    final result = await _publish(_uid);
    if (_disposed) return;
    result.fold((f) {
      _error = f.message;
      _live = false;
      _stopTicking();
    }, (code) => _code = code);
    notifyListeners();
  }

  void _tick() {
    final left = _deadline.difference(_clock.now());
    if (left.isNegative) {
      _expired = true;
      _withdraw();
    } else {
      _remaining = left;
    }
    notifyListeners();
  }

  void _withdraw() {
    _stopTicking();
    if (!_live) return;
    _live = false;
    unawaited(_clear(_uid));
  }

  void _stopTicking() {
    unawaited(_ticking?.cancel());
    _ticking = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _withdraw();
    super.dispose();
  }
}
