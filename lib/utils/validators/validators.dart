export 'common_validator.dart';
export 'email_validator.dart';
export 'phone_validator.dart';

import 'package:cleer/utils/validators/common_validator.dart';
import 'package:cleer/utils/validators/email_validator.dart';
import 'package:cleer/utils/validators/phone_validator.dart';

extension ValidationExtension on String? {
  bool get isValidName =>
      commonValidator(value: this, fieldName: '', allowOnlyLetters: true) ==
      null;
  bool get isValidPhone => nigerianPhoneValidator(this, null) == null;
  bool get isValidEmail => emailValidator(this, null) == null;
}
