import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_exceptions/amplify_api_exception_handler.dart';
import 'package:cleer/data/exceptions/backend_exception.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:result_dart/result_dart.dart';

// Mixin requires the implementing class to provide a logger
mixin AmplifyApiRepositoryMixin {
  AmplifyLogger get log;

  Future<ResultDart<Unit, DataFailure>> performVoidOperation({
    required Future<void> Function() operation,
    required String operationName,
    String? targetId,
    String? targetDetails,
  }) async {
    try {
      log.info('Starting $operationName (ID: $targetId)...');

      await operation();

      log.info('Successfully completed $operationName (ID: $targetId)');
      return Success.unit();
    } on BackendException catch (e, st) {
      log.error(
        'Server Logic Error during $operationName (ID: $targetId): ${e.message}',
        e,
        st,
      );
      // Map server logic error to general API failure
      return Failure(DataFailure.unknown(code: e.code, message: e.message));
    } on ApiException catch (e, st) {
      // Catches SDK exceptions (Network, Timeout, etc.)
      log.error(
        'SDK/Network Error during $operationName (ID: $targetId): ${e.message}',
        e,
        st,
      );
      // Map a network/system failure to a DataFailure
      return Failure(DataFailure.unknown(message: e.message));
    }
    // catch (e, st) {
    //   _log.error('Unhandled exception caught during $operationName: $e', e, stackTrace: st);
    //   return Failure(DataFailure.unknown( message: e.message));
    // }
  }

  Future<ResultDart<R, DataFailure>> performDataOperation<R extends Object>({
    required Future<R> Function() operation,
    required String operationName,
    String? targetId,
    String? targetDetails,
  }) async {
    try {
      log.info('Starting $operationName (ID: $targetId)...');

      final result = await operation();

      log.info('Successfully completed $operationName (ID: $targetId)');
      return Success(result);
    } on BackendException catch (e, st) {
      log.error(
        'Server Logic Error during $operationName (ID: $targetId): ${e.message}',
        e,
        st,
      );
      // Map server logic error to general API failure
      return Failure(AmplifyApiExceptionHandler.handleException(e));
    } on ApiException catch (e, st) {
      // Catches SDK exceptions (Network, Timeout, etc.)
      log.error(
        'SDK/Network Error during $operationName (ID: $targetId): ${e.message}',
        e,
        st,
      );
      // Map a network/system failure to a DataFailure
      return Failure(AmplifyApiExceptionHandler.handleException(e));
    }
    // catch (e, st) {
    //   log.error('Unhandled exception caught during $operationName: $e', e, st);
    //   return Failure(DataFailure.unknown( message: e.toString()));
    // }
  }
}
