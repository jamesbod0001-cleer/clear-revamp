export 'common_validator.dart' show commonValidator;
export 'email_validator.dart' show emailValidator;
export 'phone_validator.dart' show nigerianPhoneValidator;
export 'password_validator.dart' show passwordValidator;
export 'card_validators.dart';

import 'common_validator.dart';
import 'email_validator.dart';
import 'password_validator.dart';
import 'phone_validator.dart';

extension ValidationExtension on String? {
  // Pass empty strings for errors because these are just boolean checks for buttons
  bool get isValidName =>
      commonValidator(
        value: this,
        errorRequired: '',
        errorTooShort: '',
        errorTooLong: '',
        errorInvalid: '',
        allowOnlyLetters: true,
      ) ==
      null;

  bool get isValidPhone =>
      nigerianPhoneValidator(this, errorRequired: '', errorInvalid: '') == null;

  // FIX: Added the missing optional/required getters
  bool get isValidEmailOptional =>
      emailValidator(this, errorInvalid: '') == null;
  bool get isValidEmailRequired =>
      emailValidator(this, errorRequired: '', errorInvalid: '') == null;

  bool get isValidPassword =>
      passwordValidator(
        this,
        errorRequired: '',
        errorMinLength: '',
        errorUppercase: '',
        errorLowercase: '',
        errorDigit: '',
      ) ==
      null;
}
