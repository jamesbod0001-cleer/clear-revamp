import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/repositories/storage/amplify_storage_repository_impl.dart';
import 'package:cleer/data/services/storage/amplify_storage_service_client.dart';
import 'package:cleer/domain/failures/storage_failures.dart';
import 'package:cleer/domain/use_cases/storage/params/upload_file_params.dart';

part 'storage_repository.g.dart';

@riverpod
StorageRepository storageRepository(Ref ref) => AmplifyStorageRepositoryImpl(
  amplifyStorageServiceClient: ref.watch(amplifyStorageServiceClientProvider),
);

abstract class StorageRepository {
  Future<ResultDart<String, StorageFailure>> uploadFile(
    UploadFileParams params,
  );
  Future<ResultDart<Uri, StorageFailure>> getUrl(String path);
  Future<ResultDart<String, StorageFailure>> deleteFile(String path);
  // Future<ResultDart<List<String>, StorageFailure>> deleteFiles(List<String> paths);
}
