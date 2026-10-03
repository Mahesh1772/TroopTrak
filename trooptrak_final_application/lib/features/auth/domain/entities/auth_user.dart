import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    this.displayName,
    this.phoneNumber,
    this.email,
    this.lastSignInAt,
  });

  final String uid;
  final String? displayName;
  final String? phoneNumber;
  final String? email;

  /// Session metadata; not part of equality.
  final DateTime? lastSignInAt;

  @override
  List<Object?> get props => [uid, displayName, phoneNumber, email];
}
