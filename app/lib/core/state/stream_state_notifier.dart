import 'dart:async';

import 'package:flutter/foundation.dart';

import '../error/result.dart';
import 'view_state.dart';

/// Holds the latest value of a [ResultStream] as a [ViewState].
class StreamStateNotifier<T> extends ChangeNotifier {
  StreamStateNotifier(ResultStream<T> stream) {
    _subscription = stream.listen((result) {
      _state = result.fold((f) => ViewError<T>(f), (d) => ViewData<T>(d));
      onData(_state);
      notifyListeners();
    });
  }

  late final StreamSubscription<Object?> _subscription;
  ViewState<T> _state = ViewLoading<T>();

  ViewState<T> get state => _state;

  /// Hook for subclasses that derive extra state from each emission.
  @protected
  void onData(ViewState<T> state) {}

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
