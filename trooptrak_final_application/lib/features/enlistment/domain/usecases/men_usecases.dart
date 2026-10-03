import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/men_repository.dart';

class SoldierProfileExists implements UseCase<bool, String> {
  const SoldierProfileExists(this._repository);

  final MenRepository _repository;

  @override
  Result<bool> call(String uid) => _repository.exists(uid);
}
