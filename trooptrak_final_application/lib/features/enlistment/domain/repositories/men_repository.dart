import '../../../../core/error/result.dart';

/// Soldier self-registration records in `Men/{uid}` (R16).
abstract interface class MenRepository {
  Result<bool> exists(String uid);
}
