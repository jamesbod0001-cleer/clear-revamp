import 'package:flutter/material.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';

String getAuthErrorMessage(
  AuthFailure failure,
  BuildContext context, {
  bool inChangePassword = false,
}) {
  final AppLocalizations localizations = AppLocalizations.of(context)!;
  return switch (failure) {
    InvalidPasswordException() => localizations.invalidPasswordExceptionMessage,
    InvalidParameterException() =>
      localizations.invalidParameterExceptionMessage,
    UsernameExistsException() => localizations.usernameExistsExceptionMessage,
    CodeMismatchException() => localizations.codeMismatchExceptionMessage,
    ExpiredCodeException() => localizations.expiredCodeExceptionMessage,
    SignedOutException() => localizations.signedOutExceptionMessage,
    NotAuthorizedServiceException() =>
      inChangePassword
          ? localizations
                .yourOldPasswordIsIncorrectOrYouAreNotAuthorizedToChangePassword
          : localizations.notAuthorizedServiceExceptionMessage,
    NetworkException() => localizations.networkExceptionMessage,
    UserNotFoundException() => localizations.userNotFoundExceptionMessage,
    UnknownAuthFailure(:final code, :final message) =>
      (code == null || message == null)
          ? "code: $code, message: $message"
          : localizations.unknownExceptionMessage,
  };
}
