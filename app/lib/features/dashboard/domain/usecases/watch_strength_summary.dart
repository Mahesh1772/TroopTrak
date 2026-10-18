import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../attendance/domain/usecases/watch_parade_roster.dart';
import '../entities/strength_summary.dart';

/// The live parade roster, grouped into the dashboard's strength figures.
class WatchStrengthSummary implements StreamUseCase<StrengthSummary, NoParams> {
  const WatchStrengthSummary(this._roster);

  final WatchParadeRoster _roster;

  @override
  ResultStream<StrengthSummary> call(NoParams params) => _roster(params).map(
      (roster) => roster.map((entries) => StrengthSummary(entries: entries)));
}
