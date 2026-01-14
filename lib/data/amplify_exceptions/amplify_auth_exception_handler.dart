import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/failures/auth_failures.dart';

class AmplifyAuthExceptionHandler {
  AmplifyAuthExceptionHandler._();

  static AuthFailure handleException(AuthException e) {
    switch (e.runtimeTypeName) {
      case "InvalidPasswordException":
        return AuthFailure.invalidPasswordException();
      case "InvalidParameterException":
        return AuthFailure.invalidParameterException();
      case "UsernameExistsException":
        return AuthFailure.usernameExistsException();
      case "ExpiredCodeException":
        return AuthFailure.expiredCodeException();
      case "SignedOutException":
        return AuthFailure.signedOutException();
      case "NotAuthorizedServiceException":
        return AuthFailure.notAuthorizedServiceException();
      case "CodeMismatchException":
        return AuthFailure.codeMismatchException();
      case "NetworkException":
        return AuthFailure.networkException();
      case "UserNotFoundException":
        return AuthFailure.userNotFoundException();
      default:
        return AuthFailure.unknown(code: e.runtimeTypeName, message: e.message);
    }
  }

  static AuthFailure handleGenericException(dynamic e) {
    if (e is AuthException) {
      return handleException(e);
    } else {
      return AuthFailure.unknown(message: e.toString());
    }
  }
}
