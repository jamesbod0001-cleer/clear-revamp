import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/exceptions/backend_exception.dart';

mixin ApiErrorChecker {
  void validateResponse(GraphQLResponse response) {
    if (response.hasErrors) {
      final error = response.errors.first;
      throw BackendException(
        error.message,
        // code: error.message.contains('Authorized') ? 'Unauthorized' : null,
        code: error.errorType,
      );
    } else if (response.data == null) {
      throw BackendException('Data is null', code: 'NotFound');
    }
  }
}
