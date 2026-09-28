import 'package:cleer_core/cleer_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer_core/models/process_image_result/process_image_result.dart';

abstract class MediaRepository {
  Future<ResultDart<XFile, StorageFailure>> pickImageFromGallery();
  Future<ResultDart<List<XFile>, StorageFailure>> pickMultipleImages(int? limit);
  Future<ResultDart<ProcessImageDomainResult, StorageFailure>> processImage(
    ProcessImageParams params,
  );
  Future<ResultDart<List<XFile>, StorageFailure>> pickFiles(
    PickFilesParams params,
  );
}
