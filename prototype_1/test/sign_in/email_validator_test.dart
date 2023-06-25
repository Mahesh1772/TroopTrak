import 'package:flutter_test/flutter_test.dart';
import 'package:prototype_1/sign_in_assets/authenticate/sign_in.dart'; // Import the file where the validator functions are defined

void main() {
  group('validateEmail', () {
    test('should return an error message for an empty email', () {
      String? result = validateEmail('');
      expect(result, 'Email can not be empty');
    });

    test('should return an error message for an invalid email address', () {
      String? result = validateEmail('invalidemail');
      expect(result, 'Invalid Email Address');
    });

    test('should return null for a valid email address', () {
      String? result = validateEmail('valid@example.com');
      expect(result, '');
    });
  });
}
