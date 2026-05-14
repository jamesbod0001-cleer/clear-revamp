import 'package:cleer_core/cleer_core.dart';

String? validateCardNumber(
  String? value, {
  required String errorRequired,
  required String errorTooShort,
  required String errorTooLong,
  required String errorInvalidLuhn,
}) {
  final cleanValue = value?.replaceAll(RegExp(r'\D'), '') ?? '';

  final basicError = commonValidator(
    value: cleanValue,
    errorRequired: errorRequired,
    errorTooShort: errorTooShort,
    errorTooLong: errorTooLong,
    errorInvalid: errorInvalidLuhn, // Fallback
    minLength: 13,
    maxLength: 19,
  );
  if (basicError != null) return basicError;

  int sum = 0;
  bool alternate = false;
  for (int i = cleanValue.length - 1; i >= 0; i--) {
    int n = int.parse(cleanValue[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }

  return (sum % 10 != 0) ? errorInvalidLuhn : null;
}

String? validateExpiryDate(
  String? value, {
  required String errorRequired,
  required String errorFormat,
  required String errorMonth,
  required String errorExpired,
  required String errorYear,
}) {
  if (value == null || value.isEmpty) return errorRequired;

  final parts = value.split('/');
  if (parts.length != 2) return errorFormat;

  final month = int.tryParse(parts[0]) ?? 0;
  final year = int.tryParse(parts[1]) ?? 0;

  if (month < 1 || month > 12) return errorMonth;

  final now = DateTime.now();
  final currentYear = now.year % 100;
  final currentMonth = now.month;

  if (year < currentYear || (year == currentYear && month < currentMonth)) {
    return errorExpired;
  }
  if (year > currentYear + 20) return errorYear;

  return null;
}

String? validateCVV(
  String? value,
  CardNetwork network, {
  required String errorRequired,
  required String errorLength,
  required String errorInvalid,
}) {
  final cleanValue = value?.trim() ?? '';
  final expectedLength = (network == CardNetwork.americanExpress) ? 4 : 3;

  if (cleanValue.isEmpty) return errorRequired;
  if (cleanValue.length != expectedLength) return errorLength;
  if (int.tryParse(cleanValue) == null) return errorInvalid;

  return null;
}
