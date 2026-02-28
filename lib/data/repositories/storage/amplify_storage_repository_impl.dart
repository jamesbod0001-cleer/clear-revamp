import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer/data/amplify_exceptions/amplify_storage_exception_handler.dart';
import 'package:cleer/data/repositories/storage/storage_repository.dart';
import 'package:cleer/data/services/storage/amplify_storage_service_client.dart';
import 'package:cleer/data/services/storage/models/upload_file/upload_file_request.dart';
import 'package:cleer/domain/failures/storage_failures.dart';
import 'package:cleer/domain/use_cases/storage/params/upload_file_params.dart';

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
      final result = await _amplifyStorageServiceClient.uploadFile(request);
      _log.info(
        'File uploaded successfully to storage with path: ${params.path}',
      );
      return Success(result);
    } on StorageException catch (e) {
      _log.error('Error uploading file to storage: $e');
      return Failure(AmplifyStorageExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<Uri, StorageFailure>> getUrl(String path) async {
    _log.info('Getting URL for path: $path');
    try {
      final result = await _amplifyStorageServiceClient.getUrl(path);
      _log.info('Got URL for path: $path');
      return Success(result);
    } on StorageException catch (e) {
      _log.error('Error getting URL for path: $path: $e');
      return Failure(AmplifyStorageExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<String, StorageFailure>> deleteFile(String path) async {
    _log.info('Deleting file with path: $path');
    try {
      final result = await _amplifyStorageServiceClient.removeFile(path);
      _log.info('File deleted successfully with path: $path');
      return Success(result.removedItem.path);
    } on StorageException catch (e) {
      _log.error('Error deleting file with path: $path: $e');
      return Failure(AmplifyStorageExceptionHandler.handleException(e));
    }
  }

  // @override
  // Future<ResultDart<List<String>, StorageFailure>> deleteFiles(
  //     List<String> paths,
  //     ) async {
  //   _log.info('Deleting files with paths: $paths');
  //   try {
  //     final result = await _amplifyStorageServiceClient.removeManyFiles(paths);
  //     final successfullyDeletedFiles = result.removedItems
  //         .map((item) => item.path)
  //         .toList();
  //     _log.info(
  //       'Successfully deleted files with paths: $successfullyDeletedFiles',
  //     );
  //     if (result.errors.isEmpty) {
  //       _log.info('No errors occurred while deleting files');
  //       return Success(successfullyDeletedFiles);
  //     } else {
  //       _log.error('Errors occurred while deleting files: ${result.errors}');
  //       return Success(successfullyDeletedFiles);
  //     }
  //   } on StorageException catch (e) {
  //     _log.error('Error deleting files: $e');
  //     return Failure(AmplifyStorageExceptionHandler.handleException(e));
  //   }
  // }
}
