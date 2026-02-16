import 'package:cleer/domain/models/enums/card_network.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/utils/validators/common_validator.dart';

String? validateCardNumber(String? value, AppLocalizations? l10n) {
  final cleanValue = value?.replaceAll(RegExp(r'\D'), '') ?? '';

  // Reuse your common logic for basic checks
  final basicError = commonValidator(
    value: cleanValue,
    fieldName: l10n?.cardNumber ?? 'Card number',
    minLength: 13, // Some cards like Verve/Visa can be 13-19 digits
    maxLength: 19,
    l10n: l10n,
  );
  if (basicError != null) return basicError;

  // Luhn Algorithm Check
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

  if (sum % 10 != 0) {
    return l10n?.invalidCardNumber ?? "Invalid card number";
  }

  return null;
}

String? validateExpiryDate(String? value, AppLocalizations? l10n) {
  if (value == null || value.isEmpty) {
    return l10n?.fieldRequired(l10n.expiryDate.toLowerCase()) ??
        "Expiry is required";
  }

  final parts = value.split('/');
  if (parts.length != 2) {
    return l10n?.invalidExpiryDate ?? "Invalid date format";
  }

  final month = int.tryParse(parts[0]) ?? 0;
  final year = int.tryParse(parts[1]) ?? 0;

  if (month < 1 || month > 12) {
    return l10n?.invalidMonth ?? "Invalid month";
  }

  // Convert YY to full year (assuming 2000s)
  final now = DateTime.now();
  final currentYear = now.year % 100;
  final currentMonth = now.month;

  if (year < currentYear || (year == currentYear && month < currentMonth)) {
    return l10n?.cardHasExpired ?? "Card has expired";
  }

  if (year > currentYear + 20) {
    return l10n?.invalidYear ?? "Invalid year";
  }

  return null;
}


String? validateCVV(String? value, CardNetwork network, AppLocalizations? l10n) {
  final cleanValue = value?.trim() ?? '';
  final expectedLength = (network == CardNetwork.americanExpress) ? 4 : 3;

  if (cleanValue.isEmpty) {
    return l10n?.fieldRequired('cvv') ?? "CVV is required";
  }

  if (cleanValue.length != expectedLength) {
    return l10n?.invalidCvvLength(expectedLength) ?? "CVV must be $expectedLength digits";
  }

  if (int.tryParse(cleanValue) == null) {
    return l10n?.invalidCharacters('CVV') ?? "Invalid CVV";
  }

  return null;
}