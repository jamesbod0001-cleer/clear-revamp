import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/utils/constants.dart';

String? passwordValidator(
  String? value,
  AppLocalizations? l10n, {
  String? confirmPassword,
}) {
  final password = value ?? '';

  if (password.isEmpty) {
    return l10n?.pleaseEnterYourPassword ?? kEmpty;
  }

  if (password.length < 8) {
    return l10n?.passwordMustBeAtLeast8CharactersLong ?? kEmpty;
  }

  if (!password.contains(RegExp(r'[A-Z]'))) {
    return l10n?.passwordMustContainAtLeastOneUppercaseLetter ?? kEmpty;
  }

  if (!password.contains(RegExp(r'[a-z]'))) {
    return l10n?.passwordMustContainAtLeastOneLowercaseLetter ?? kEmpty;
  }

  if (!password.contains(RegExp(r'[0-9]'))) {
    return l10n?.passwordMustContainAtLeastOneDigit ?? kEmpty;
  }

  // if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
  //   return l10n?.passwordMustContainAtLeastOneSpecialCharacter ?? kEmpty;
  // }
  //
  // if (password.contains(' ')) {
  //   return l10n?.passwordCannotContainSpaces ?? kEmpty;
  // }

  if (confirmPassword != null && password != confirmPassword) {
    return l10n?.passwordDoesNotMatch ?? kEmpty;
  }

  return null;
}
