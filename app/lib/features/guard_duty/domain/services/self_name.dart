abstract final class SelfName {
  /// The "You" rule: [name] is the signed-in soldier's. A commander has no
  /// name to match, so nothing is theirs.
  static bool matches(String name, String? selfName) =>
      selfName != null && selfName.isNotEmpty && name == selfName;
}
