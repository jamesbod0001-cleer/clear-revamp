import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/services/amplify_providers.dart';
import 'package:cleer/data/services/storage/models/upload_file/upload_file_request.dart';

part 'amplify_storage_service_client.g.dart';

@riverpod
AmplifyStorageServiceClient amplifyStorageServiceClient(Ref ref) =>
    AmplifyStorageServiceClient(
      amplifyStorage: ref.watch(amplifyStorageProvider),
    );

class AmplifyStorageServiceClient {
  final StorageCategory _amplifyStorage;

  AmplifyStorageServiceClient({required StorageCategory amplifyStorage})
    : _amplifyStorage = amplifyStorage;

  Future<String> uploadFile(UploadFileRequest request) async {
    final uploadOperation = _amplifyStorage.uploadFile(
      localFile: AWSFile.fromPath(request.file.path),
      path: StoragePath.fromString(request.path),
      onProgress: (progress) =>
          request.onProgress?.call(progress.fractionCompleted),
    );
    final result = await uploadOperation.result;
    return result.uploadedItem.path;
  }

  Future<Uri> getUrl(String path) async {
    final result = await _amplifyStorage
        .getUrl(
          path: StoragePath.fromString(path),
          options: StorageGetUrlOptions(
            pluginOptions: S3GetUrlPluginOptions(
              expiresIn: Duration(days: 7),
              validateObjectExistence: true,
            ),
          ),
        )
        .result;
    return result.url;
  }

  Future<StorageRemoveResult<StorageItem>> removeFile(String path) async {
    final result = await _amplifyStorage
        .remove(path: StoragePath.fromString(path))
        .result;
    return result;
  }

  // Future<StorageRemoveManyResult<StorageItem, Object>> removeManyFiles(
  //   List<String> paths,
  // ) async {
  //   final result = await _amplifyStorage
  //       .removeMany(
  //         paths: paths.map((path) => StoragePath.fromString(path)).toList(),
  //       )
  //       .result;
  //   return result;
  // }
}
