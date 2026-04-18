import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/exceptions/backend_exception.dart';

mixin ApiErrorChecker {
  T? validateResponse<T>(GraphQLResponse<T> response) {
    if (response.hasErrors && response.data == null) {
      throw BackendException(
        response.errors.toString(),
      );
    }
    return response.data;
  }

  // Use this when you want to FORCE a non-null result
  T validateRequiredResponse<T>(
    GraphQLResponse<T> response, {
    String? errorMessage,
  }) {
    final data = validateResponse(response);
    if (data == null) {
      throw BackendException(
        errorMessage ?? 'Required data was not found',
        code: 'NotFound',
      );
    }
    return data;
  }
}
