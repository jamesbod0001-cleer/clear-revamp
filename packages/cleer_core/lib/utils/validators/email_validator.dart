// packages/cleer_core/lib/utils/validators/email_validator.dart
String? emailValidator(
  String? value, {
  required String errorInvalid,
  String? errorRequired,
}) {
  final trimmedValue = value?.trim() ?? '';
  if (trimmedValue.isEmpty) return errorRequired;

  final bool emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(trimmedValue);

  return emailValid ? null : errorInvalid;
}
