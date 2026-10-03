import '../error/failures.dart';

sealed class ViewState<T> {
  const ViewState();

  T? get dataOrNull => switch (this) {
        ViewData<T>(:final data) => data,
        _ => null,
      };

  bool get isLoading => this is ViewLoading<T>;
}

final class ViewLoading<T> extends ViewState<T> {
  const ViewLoading();
}

final class ViewError<T> extends ViewState<T> {
  const ViewError(this.failure);

  final Failure failure;
}

final class ViewData<T> extends ViewState<T> {
  const ViewData(this.data);

  final T data;
}
