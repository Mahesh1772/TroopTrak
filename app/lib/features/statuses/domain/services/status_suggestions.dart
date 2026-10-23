import '../../../../core/constants/status_names.dart';
import '../../../../core/constants/status_types.dart';

/// Quick picks for the name of a status; only an Excuse has them.
///
/// With nothing typed they are the common names. Typing narrows them to the
/// names containing the text, ignoring case. A name typed or picked in full
/// keeps the common names showing, so the choice stays among them.
List<String> suggestStatusNames(String? type, String typed) {
  if (type != StatusTypes.excuse) return const [];
  final query = typed.trim().toLowerCase();
  if (query.isEmpty) return StatusNames.common;
  final all = [for (final name in StatusNames.suggestions) name.trim()];
  final exact = all.where((name) => name.toLowerCase() == query);
  if (exact.isNotEmpty) return {...StatusNames.common, ...exact}.toList();
  return [
    for (final name in all)
      if (name.toLowerCase().contains(query)) name,
  ];
}
