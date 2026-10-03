import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/men_repository.dart';
import '../datasources/men_remote_data_source.dart';

class MenRepositoryImpl implements MenRepository {
  MenRepositoryImpl(this._remote);

  final MenRemoteDataSource _remote;

  @override
  Result<bool> exists(String uid) => guard(() => _remote.exists(uid));
}
