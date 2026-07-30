import 'dart:async'; // 🔴 Added for TimeoutException
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/exceptions/amplify/amplify_storage_exception_handler.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer_api/src/services/storage/amplify_storage_service_client.dart';
import 'package:cleer_api/src/services/storage/models/upload_file/upload_file_request.dart';

class AmplifyStorageRepositoryImpl extends StorageRepository {
  final AmplifyStorageServiceClient _amplifyStorageServiceClient;

  AmplifyStorageRepositoryImpl({
    required AmplifyStorageServiceClient amplifyStorageServiceClient,
  }) : _amplifyStorageServiceClient = amplifyStorageServiceClient;

  final _log = AmplifyLogger('AmplifyStorageRepositoryImpl');

  @override
  Future<ResultDart<String, StorageFailure>> uploadFile(
      UploadFileParams params,
      ) async {
    _log.info('Uploading file to storage with path: ${params.path}');
    try {
      final request = UploadFileRequest(
        file: params.file,
        path: params.path,
        onProgress: params.onProgress,
      );

      // 🔴 60-Second Timeout applied here for heavy file uploads
      final result = await _amplifyStorageServiceClient.uploadFile(request).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('File upload timed out'),
      );

      _log.info(
        'File uploaded successfully to storage with path: ${params.path}',
      );
      return Success(result);
    } on TimeoutException catch (_) {
      _log.error('Upload timeout for path: ${params.path}');
      // Assuming your StorageFailure has an unknown or network constructor
      return const Failure(StorageFailure.unknown(message: 'Upload timed out. Please check your internet connection.'));
    } on StorageException catch (e) {
      _log.error('Error uploading file to storage: $e');
      return Failure(AmplifyStorageExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<Uri, StorageFailure>> getUrl(String path) async {
    _log.info('Getting URL for path: $path');
    try {
      // 🔴 15-second timeout is fine here since it just fetches a string URL, not the file itself
      final result = await _amplifyStorageServiceClient.getUrl(path).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      _log.info('Got URL for path: $path');
      return Success(result);
    } on TimeoutException catch (_) {
      return const Failure(StorageFailure.unknown(message: 'Request timed out.'));
    } on StorageException catch (e) {
      _log.error('Error getting URL for path: $path: $e');
      return Failure(AmplifyStorageExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<String, StorageFailure>> deleteFile(String path) async {
    _log.info('Deleting file with path: $path');
    try {
      final result = await _amplifyStorageServiceClient.removeFile(path).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      _log.info('File deleted successfully with path: $path');
      return Success(result.removedItem.path);
    } on TimeoutException catch (_) {
      return const Failure(StorageFailure.unknown(message: 'Request timed out.'));
    } on StorageException catch (e) {
      _log.error('Error deleting file with path: $path: $e');
      return Failure(AmplifyStorageExceptionHandler.handleException(e));
    }
  }
}