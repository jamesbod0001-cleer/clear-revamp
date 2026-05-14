import 'package:cleer_core/cleer_core.dart' as cleer_core;
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
import 'package:flutter/widgets.dart';

extension ValidationContext on BuildContext {
  UiLocalizations get _l10n => UiLocalizations.of(this)!;

  /// Generic Validator
  String? Function(String?) commonValidator(String fieldName, {int min = 2}) {
    return (val) => cleer_core.commonValidator(
      value: val,
      errorRequired: _l10n.fieldRequired(fieldName.toLowerCase()),
      errorTooShort: _l10n.fieldTooShort(fieldName, min),
      errorTooLong: _l10n.fieldTooLong(fieldName, 50),
      errorInvalid: _l10n.invalidCharacters(fieldName),
      minLength: min,
    );
  }

  /// Phone Validator
  String? Function(String?) get phoneValidator {
    return (val) => cleer_core.nigerianPhoneValidator(
      val,
      errorRequired: _l10n.fieldRequired("phone number"),
      errorInvalid: _l10n.invalidPhoneNumber,
    );
  }

  /// Email Validator
  String? Function(String?) emailValidator({bool isRequired = true}) {
    return (val) => cleer_core.emailValidator(
      val,
      errorRequired: isRequired ? _l10n.fieldRequired("email") : null,
      errorInvalid: _l10n.invalidEmailAddress,
    );
  }

  /// Password Validator
  String? Function(String?) passwordValidator({String? confirmPassword}) {
    return (val) => cleer_core.passwordValidator(
      val,
      confirmPassword: confirmPassword,
      errorRequired: _l10n.pleaseEnterYourPassword,
      errorMinLength: _l10n.passwordMustBeAtLeast8CharactersLong,
      errorUppercase: _l10n.passwordMustContainAtLeastOneUppercaseLetter,
      errorLowercase: _l10n.passwordMustContainAtLeastOneLowercaseLetter,
      errorDigit: _l10n.passwordMustContainAtLeastOneDigit,
      errorMismatch: _l10n.passwordDoesNotMatch,
    );
  }

  /// Card Number Validator
  String? Function(String?) get cardNumberValidator {
    return (val) => cleer_core.validateCardNumber(
      val,
      errorRequired: _l10n.fieldRequired("card number"),
      errorTooShort: _l10n.fieldTooShort("Card number", 13),
      errorTooLong: _l10n.fieldTooLong("Card number", 19),
      errorInvalidLuhn: _l10n.invalidCardNumber,
    );
  }

  /// Expiry Date Validator
  String? Function(String?) get expiryDateValidator {
    return (val) => cleer_core.validateExpiryDate(
      val,
      errorRequired: _l10n.fieldRequired("expiry date"),
      errorFormat: _l10n.invalidExpiryDate,
      errorMonth: _l10n.invalidMonth,
      errorExpired: _l10n.cardHasExpired,
      errorYear: _l10n.invalidYear,
    );
  }

  /// CVV Validator
  String? Function(String?) cvvValidator(CardNetwork network) {
    final expected = network == CardNetwork.americanExpress ? 4 : 3;
    return (val) => cleer_core.validateCVV(
      val,
      network,
      errorRequired: _l10n.fieldRequired("cvv"),
      errorLength: _l10n.invalidCvvLength(expected),
      errorInvalid: _l10n.invalidCharacters("CVV"),
    );
  }
}
