/// R20 soldier name rule, shared by profile capture, register and the
/// commander soldier form. Messages are the source's own texts.
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
}
