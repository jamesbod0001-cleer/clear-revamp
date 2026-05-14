import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/exceptions/backend_exception.dart';
import 'package:cleer_core/cleer_core.dart';

class AmplifyApiExceptionHandler {
  AmplifyApiExceptionHandler._();

  static DataFailure handleException(Object e) {
    // Use pattern matching to extract the correct code and message based on type
    final (code, message) = switch (e) {
      ApiException e => (e.runtimeTypeName, e.message),
      BackendException e => (e.code ?? "BackendException", e.message),
      _ => ("UnknownException", e.toString()),
    };

    // Logic based on the normalized code
    switch (code) {
      case "UnauthorizedException":
        return DataFailure.unauthorizedException();
      case "NotFound":
        return DataFailure.notFound();
      case "DynamoDB:ConditionalCheckFailedException":
        return DataFailure.conditionalCheckFailed();
      default:
        return DataFailure.unknown(code: code, message: message);
    }
  }

  static DataFailure handleGenericException(dynamic e) {
    if (e is ApiException) {
      return handleException(e);
    } else {
      return DataFailure.unknown(message: e.toString());
    }
  }
}
