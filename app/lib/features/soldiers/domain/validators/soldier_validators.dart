/// R20 soldier rules, shared by profile capture, register and the commander
/// soldier form. Messages are the source's own texts.
abstract final class SoldierValidators {
  static final _numeric = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

  /// Source rule: rejects an all-numeric name, not a name containing a digit.
  static String? name(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Must have a name right';
    if (_numeric.hasMatch(v)) return 'Name got number meh';
    if (v.length < 5) return 'Brother, enter full name leh';
    return null;
  }

  static String? appointment(String? value) =>
      _filled(value, 'Appointment Missing');

  static String? company(String? value) =>
      _filled(value, 'Company Name Missing');

  static String? platoon(String? value) =>
      _filled(value, 'Platoon Information Missing');

  static String? section(String? value) =>
      _filled(value, 'Section Information Missing');

  static String? rationType(String? value) =>
      value == null ? 'Walao what food you eat?' : null;

  static String? rank(String? value) =>
      value == null ? 'Walao provide rank liao' : null;

  static String? bloodGroup(String? value) =>
      value == null ? 'Why your blood field empty ah?' : null;

  static String? dateOfBirth(DateTime? value) =>
      value == null ? 'Select your date of birth' : null;

  static String? enlistmentDate(DateTime? value) =>
      value == null ? 'Select your enlistment date' : null;

  static String? ordDate(DateTime? value) =>
      value == null ? 'Select your ORD date' : null;

  static String? _filled(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;
}
