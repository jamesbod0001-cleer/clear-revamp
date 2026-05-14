import 'package:cleer_core/utils/constants.dart';

String? nigerianPhoneValidator(
  String? value, {
  String errorRequired = kEmpty,
  String errorInvalid = kEmpty,
}) {
  // 1. Remove the spaces added by the formatter to get just the digits
  final cleanNumber = value?.replaceAll(' ', '') ?? '';

  if (cleanNumber.isEmpty) {
    return errorRequired;
  }

  // 2. Check for exactly 10 digits
  // (Because the formatter already stripped the '0' and restricted length)
  if (cleanNumber.length != 10) {
    return errorInvalid; // e.g., "Please enter a valid 10-digit number"
  }

  // 3. Optional: Validate Nigerian mobile prefixes (7, 8, or 9)
  // Nigerian numbers start with 070, 080, 081, 090, 091, etc.
  // Since we stripped the '0', we check if it starts with 7, 8, or 9.
  final bool hasValidPrefix = RegExp(r'^[789]').hasMatch(cleanNumber);
  if (!hasValidPrefix) {
    return errorInvalid;
  }

  return null; // Valid!
}
