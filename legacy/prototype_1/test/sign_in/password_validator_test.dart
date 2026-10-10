import 'package:flutter_test/flutter_test.dart';
import 'package:prototype_1/sign_in_assets/authenticate/sign_in.dart'; // Import the file where the validator functions are defined

void main() {
  group('validatePassword', () {
    test('should return an error message for an empty password', () {
      String? result = validatePassword('');
      expect(result, 'Password can not be empty');
    });

    test('should return an error message for a password less than 8 characters',
        () {
      String? result = validatePassword('pass');
      expect(result, 'Password should be at least 8 characters long');
    });

    test('should return null for a valid password', () {
      String? result = validatePassword('validpassword');
      expect(result, '');
    });
  });
}
