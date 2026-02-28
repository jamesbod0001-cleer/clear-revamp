import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/failures/storage_failures.dart';

class AmplifyStorageExceptionHandler {
  AmplifyStorageExceptionHandler._();

  static StorageFailure handleException(StorageException e) {
    switch (e.runtimeTypeName) {
      case "StorageAccessDeniedException":
        return StorageFailure.storageAccessDeniedException();
      case "CanceledException":
        return StorageFailure.canceled();
      default:
        return StorageFailure.unknown(
          code: e.runtimeTypeName,
          message: e.message,
        );
    }
  }

  static StorageFailure handleGenericException(dynamic e) {
    if (e is StorageException) {
      return handleException(e);
    } else {
      return StorageFailure.unknown(message: e.toString());
    }
  }
}
