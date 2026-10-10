/// Commander register password checklist (source flutter_pw_validator settings).
enum PasswordRule {
  minLength('At least 8 characters'),
  uppercase('1 uppercase letter'),
  lowercase('3 lowercase letters'),
  digit('1 number'),
  special('1 special character');

  const PasswordRule(this.label);

  final String label;

  bool passes(String password) => switch (this) {
        PasswordRule.minLength => password.length >= 8,
        PasswordRule.uppercase => RegExp('[A-Z]').hasMatch(password),
        PasswordRule.lowercase =>
          RegExp('[a-z]').allMatches(password).length >= 3,
        PasswordRule.digit => RegExp('[0-9]').hasMatch(password),
        PasswordRule.special => RegExp(r'[^A-Za-z0-9\s]').hasMatch(password),
      };

  static bool isStrong(String password) =>
      values.every((rule) => rule.passes(password));
}
