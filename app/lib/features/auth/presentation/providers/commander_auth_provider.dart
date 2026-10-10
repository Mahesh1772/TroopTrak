import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/register_commander.dart';

enum CommanderAuthMode { signIn, register }

class CommanderAuthProvider extends ChangeNotifier {
  CommanderAuthProvider({
    required SignInWithEmail signIn,
    required RegisterCommander register,
    required SendPasswordReset sendReset,
  })  : _signIn = signIn,
        _register = register,
        _sendReset = sendReset;

  static const signInFailed = 'Wrong Email/Password or Both';
  static const registerFailed = 'This Email in use/ Enter Email and Password';

  final SignInWithEmail _signIn;
  final RegisterCommander _register;
  final SendPasswordReset _sendReset;

  CommanderAuthMode _mode = CommanderAuthMode.signIn;
  bool _loading = false;

  CommanderAuthMode get mode => _mode;
  bool get loading => _loading;

  void toggleMode() {
    _mode = _mode == CommanderAuthMode.signIn
        ? CommanderAuthMode.register
        : CommanderAuthMode.signIn;
    notifyListeners();
  }

  /// Returns null on success, otherwise the message to show.
  Future<String?> signIn(String email, String password) => _run(
        () => _signIn(EmailCredentials(email, password)),
        fallback: signInFailed,
      );

  /// On success switches back to sign in, as the source did after sign-out.
  Future<String?> register(CommanderRegistration registration) async {
    final error =
        await _run(() => _register(registration), fallback: registerFailed);
    if (error == null) {
      _mode = CommanderAuthMode.signIn;
      notifyListeners();
    }
    return error;
  }

  Future<String?> sendPasswordReset(String email) async {
    _loading = true;
    notifyListeners();
    final result = await _sendReset(email);
    _loading = false;
    notifyListeners();
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> _run<T>(
    Result<T> Function() action, {
    required String fallback,
  }) async {
    _loading = true;
    notifyListeners();
    final result = await action();
    _loading = false;
    notifyListeners();
    return result.fold(
      (f) => f is ValidationFailure ? f.message : fallback,
      (_) => null,
    );
  }
}
