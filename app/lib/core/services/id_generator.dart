import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String next();
}

/// Random v4 UUIDs from a cryptographic RNG (the uuid default).
final class UuidGenerator implements IdGenerator {
  const UuidGenerator();

  @override
  String next() => const Uuid().v4();
}
