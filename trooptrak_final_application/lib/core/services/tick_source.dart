/// Periodic beat behind countdowns, injectable so they are testable.
abstract interface class TickSource {
  Stream<void> every(Duration period);
}

final class PeriodicTickSource implements TickSource {
  const PeriodicTickSource();

  @override
  Stream<void> every(Duration period) => Stream<void>.periodic(period);
}
