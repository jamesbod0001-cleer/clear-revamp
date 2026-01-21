import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/utils/constants.dart';

String? emailValidator(
  String? value,
  AppLocalizations? l10n, {
  bool isRequired = false,
}) {
  final trimmedValue = value?.trim() ?? '';
  if (trimmedValue.isEmpty) {
    if (isRequired) {
      return l10n?.fieldRequired("email") ?? kEmpty;
    } else {
      return null;
    }
  }

  final bool emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(trimmedValue);

  return emailValid ? null : (l10n?.invalidEmailAddress ?? kEmpty);
}
