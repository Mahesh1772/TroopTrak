import 'package:equatable/equatable.dart';

import '../../../soldiers/domain/entities/soldier.dart';

/// A soldier's self-registration in `Men/{uid}` (R16).
class SoldierRegistration extends Equatable {
  const SoldierRegistration({
    required this.uid,
    required this.profile,
    this.qrId,
  });

  final String uid;

  /// Profile fields; `profile.id` is the trimmed name, the `Users` id the
  /// commander side links by (K8).
  final Soldier profile;

  /// Live enlistment QR code (R15), null when none is shown.
  final String? qrId;

  @override
  List<Object?> get props => [uid, profile, qrId];
}
