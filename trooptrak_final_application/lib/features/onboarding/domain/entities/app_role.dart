/// Stored in the `onBoard` preference (R18).
enum AppRole {
  soldier(1),
  commander(2);

  const AppRole(this.value);

  final int value;

  static AppRole? fromValue(int? value) {
    for (final role in values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
