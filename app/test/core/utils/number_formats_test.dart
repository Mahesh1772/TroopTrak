import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/utils/number_formats.dart';

void main() {
  test('points show one decimal', () {
    expect(formatPoints(5.5), '5.5');
    expect(formatPoints(2), '2.0');
    expect(formatPoints(0), '0.0');
  });
}
