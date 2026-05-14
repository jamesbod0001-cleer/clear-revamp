// packages/cleer_core/lib/utils/validators/password_validator.dart
String? passwordValidator(
  String? value, {
  required String errorRequired,
  required String errorMinLength,
  required String errorUppercase,
  required String errorLowercase,
  required String errorDigit,
  String? confirmPassword,
  String? errorMismatch,
}) {
  final password = value ?? '';
  if (password.isEmpty) return errorRequired;
  if (password.length < 8) return errorMinLength;
  if (!password.contains(RegExp(r'[A-Z]'))) return errorUppercase;
  if (!password.contains(RegExp(r'[a-z]'))) return errorLowercase;
  if (!password.contains(RegExp(r'[0-9]'))) return errorDigit;
  if (confirmPassword != null && password != confirmPassword) {
    return errorMismatch;
  }

  return null;
}
