import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failures.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidPasswordException() =
      InvalidPasswordException;
  const factory AuthFailure.invalidParameterException() =
      InvalidParameterException;
  const factory AuthFailure.usernameExistsException() = UsernameExistsException;
  const factory AuthFailure.codeMismatchException() = CodeMismatchException;
  const factory AuthFailure.expiredCodeException() = ExpiredCodeException;
  const factory AuthFailure.signedOutException() = SignedOutException;
  const factory AuthFailure.notAuthorizedServiceException() =
      NotAuthorizedServiceException;
  const factory AuthFailure.userNotFoundException() = UserNotFoundException;
  const factory AuthFailure.networkException() = NetworkException;
  const factory AuthFailure.userLambdaValidationException({String? message}) =
      UserLambdaValidationException;
  const factory AuthFailure.unknown({String? code, String? message}) =
      UnknownAuthFailure;
}
