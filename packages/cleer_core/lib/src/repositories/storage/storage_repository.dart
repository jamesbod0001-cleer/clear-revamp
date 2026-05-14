import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class StorageRepository {
  Future<ResultDart<String, StorageFailure>> uploadFile(
    UploadFileParams params,
  );
  Future<ResultDart<Uri, StorageFailure>> getUrl(String path);
  Future<ResultDart<String, StorageFailure>> deleteFile(String path);
  // Future<ResultDart<List<String>, StorageFailure>> deleteFiles(List<String> paths);
}
