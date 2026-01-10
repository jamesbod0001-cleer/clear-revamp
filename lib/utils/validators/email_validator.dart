import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/utils/constants.dart';

String? emailValidator(String? value, AppLocalizations? l10n) {
  final trimmedValue = value?.trim() ?? '';
  if (trimmedValue.isEmpty) return null; // Email is optional

  final bool emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(trimmedValue);

  return emailValid ? null : (l10n?.invalidEmailAddress ?? kEmpty);
}
