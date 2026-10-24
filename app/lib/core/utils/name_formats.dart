/// The last word of [name], for a space too small for the whole name.
String formatShortName(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  return words.last;
}
