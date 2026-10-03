import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/phone_auth_event.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/soldier_entry.dart';
import '../../domain/validators/auth_validators.dart';

enum PhoneOutcome { codeSent, home, profileCapture, failed }

/// Soldier phone sign-in. The verification id stays here, not in a global (K10).
class PhoneAuthProvider extends ChangeNotifier {
  PhoneAuthProvider({
    required VerifyPhone verifyPhone,
    required VerifyOtp verifyOtp,
    required CompleteSoldierSignIn completeSignIn,
  })  : _verifyPhone = verifyPhone,
        _verifyOtp = verifyOtp,
        _complete = completeSignIn;

  final VerifyPhone _verifyPhone;
  final VerifyOtp _verifyOtp;
  final CompleteSoldierSignIn _complete;

  StreamSubscription<PhoneAuthEvent>? _subscription;
  String? _phoneNumber;
  String? _verificationId;
  int? _resendToken;
  bool _busy = false;
  String? _error;
  PhoneOutcome? _autoOutcome;

  String? get verificationId => _verificationId;
  String? get phoneNumber => _phoneNumber;
  bool get busy => _busy;
  String? get error => _error;

  /// Outcome reached by Android auto-verification while the OTP page is open.
  PhoneOutcome? takeAutoOutcome() {
    final outcome = _autoOutcome;
    _autoOutcome = null;
    return outcome;
  }

  Future<PhoneOutcome> sendCode(String dialCode, String localNumber) {
    final invalid = AuthValidators.phoneNumber(localNumber);
    if (invalid != null) return Future.value(_fail(invalid));
    _phoneNumber = '+$dialCode${localNumber.replaceAll(RegExp(r'\s'), '')}';
    return _start(resendToken: null);
  }

  Future<PhoneOutcome> resend() {
    if (_phoneNumber == null) return Future.value(PhoneOutcome.failed);
    return _start(resendToken: _resendToken);
  }

  Future<PhoneOutcome> submitOtp(String code) async {
    final id = _verificationId;
    if (id == null) return _fail('Request a new OTP first.');
    _setBusy(true);
    final result = await _verifyOtp(OtpParams(id, code));
    return result.fold((f) => _fail(f.message), _finish);
  }

  Future<PhoneOutcome> _start({required int? resendToken}) {
    final first = Completer<PhoneOutcome>();
    _setBusy(true);
    _error = null;
    unawaited(_subscription?.cancel());
    _subscription = _verifyPhone(
      PhoneParams(_phoneNumber!, resendToken: resendToken),
    ).listen((event) async {
      final outcome = await _handle(event);
      if (outcome == null) return;
      if (!first.isCompleted) {
        first.complete(outcome);
      } else if (outcome != PhoneOutcome.failed) {
        _autoOutcome = outcome;
        notifyListeners();
      }
    });
    return first.future;
  }

  Future<PhoneOutcome?> _handle(PhoneAuthEvent event) async {
    switch (event) {
      case OtpSent(:final verificationId, :final resendToken):
        _verificationId = verificationId;
        _resendToken = resendToken;
        _setBusy(false);
        return PhoneOutcome.codeSent;
      case PhoneAutoVerified(:final user):
        return _finish(user);
      case PhoneVerificationError(:final failure):
        return _fail(failure.message);
      case OtpTimeout(:final verificationId):
        _verificationId ??= verificationId;
        return null;
    }
  }

  Future<PhoneOutcome> _finish(AuthUser user) async {
    final entry = await _complete(user);
    return entry.fold((f) => _fail(f.message), (e) {
      _setBusy(false);
      return e == SoldierEntry.home
          ? PhoneOutcome.home
          : PhoneOutcome.profileCapture;
    });
  }

  PhoneOutcome _fail(String message) {
    _error = message;
    _busy = false;
    notifyListeners();
    return PhoneOutcome.failed;
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
