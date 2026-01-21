import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/utils/constants.dart';

String? commonValidator({
  required String? value,
  required String fieldName,
  AppLocalizations? l10n,
  int minLength = 2,
  int maxLength = 50,
  bool allowOnlyLetters = false,
}) {
  final trimmedValue = value?.trim() ?? '';

  if (trimmedValue.isEmpty) {
    return l10n?.fieldRequired(fieldName.toLowerCase()) ?? kEmpty;
  }

  if (trimmedValue.length < minLength) {
    return l10n?.fieldTooShort(fieldName, minLength) ?? kEmpty;
  }

  if (trimmedValue.length > maxLength) {
    return l10n?.fieldTooLong(fieldName, maxLength) ?? kEmpty;
  }

  if (allowOnlyLetters) {
    // Improved regex to allow international accented characters
    final RegExp nameRegex = RegExp(r"^[a-zA-Z\s\-\u00C0-\u017F]+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return l10n?.invalidCharacters(fieldName) ?? kEmpty;
    }
  }

  return null;
}
