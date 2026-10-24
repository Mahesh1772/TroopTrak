import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/utils/name_formats.dart';

void main() {
  test('a short name is its last word', () {
    expect(formatShortName('Tan Ah Kow'), 'Kow');
    expect(formatShortName('Lee'), 'Lee');
    expect(formatShortName('  Lim   Bah '), 'Bah');
    expect(formatShortName(''), '');
  });
}
