// packages/cleer_core/lib/utils/validators/common_validator.dart
String? commonValidator({
  required String? value,
  required String errorRequired,
  required String errorTooShort,
  required String errorTooLong,
  required String errorInvalid,
  int minLength = 2,
  int maxLength = 50,
  bool allowOnlyLetters = false,
}) {
  final trimmedValue = value?.trim() ?? '';

  if (trimmedValue.isEmpty) return errorRequired;
  if (trimmedValue.length < minLength) return errorTooShort;
  if (trimmedValue.length > maxLength) return errorTooLong;

  if (allowOnlyLetters) {
    final RegExp nameRegex = RegExp(r"^[a-zA-Z\s\-\u00C0-\u017F]+$");
    if (!nameRegex.hasMatch(trimmedValue)) return errorInvalid;
  }

  return null;
}
