import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/services/clock.dart';

void main() {
  test('SystemClock returns the current time', () {
    final before = DateTime.now();
    final now = const SystemClock().now();
    final after = DateTime.now();

    expect(now.isBefore(before), isFalse);
    expect(now.isAfter(after), isFalse);
  });
}
