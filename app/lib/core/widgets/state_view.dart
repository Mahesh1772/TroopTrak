import 'package:flutter/material.dart';

import '../state/view_state.dart';
import 'feedback_views.dart';

class StateView<T> extends StatelessWidget {
  const StateView({
    super.key,
    required this.state,
    required this.builder,
    this.isEmpty,
    this.empty,
    this.onRetry,
  });

  final ViewState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ViewLoading<T>() => const LoadingView(),
      ViewError<T>(:final failure) =>
        ErrorView(message: failure.message, onRetry: onRetry),
      ViewData<T>(:final data) => (isEmpty?.call(data) ?? false)
          ? (empty ??
              const EmptyState(message: 'Nothing here yet', image: null))
          : builder(context, data),
    };
  }
}
