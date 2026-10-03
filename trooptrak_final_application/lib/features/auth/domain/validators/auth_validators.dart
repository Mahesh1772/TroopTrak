/// R20 validators. Messages are the source's own texts.
abstract final class AuthValidators {
  static final _email = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
    r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );
  static final _numeric = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email can not be empty';
    if (!_email.hasMatch(v)) return 'Invalid Email Address';
    return null;
  }

  static String? password(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Password can not be empty';
    if (v.length < 8) return 'Password should be at least 8 characters long';
    return null;
  }

  static String? confirmPassword(String? value, String password) =>
      (value?.trim() ?? '') == password.trim()
          ? null
          : 'Passwords do not match';

  /// Source rule: rejects an all-numeric name, not a name containing a digit.
  static String? soldierName(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Must have a name right';
    if (_numeric.hasMatch(v)) return 'Name got number meh';
    if (v.length < 5) return 'Brother, enter full name leh';
    return null;
  }

  static String? phoneNumber(String? value) {
    final digits = value?.replaceAll(RegExp(r'\s'), '') ?? '';
    if (digits.isEmpty) return 'Enter your phone number';
    if (!RegExp(r'^[0-9]{6,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? otp(String? value) =>
      RegExp(r'^[0-9]{6}$').hasMatch(value ?? '') ? null : 'Enter 6 digit code';
}
