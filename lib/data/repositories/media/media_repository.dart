import 'package:image_picker/image_picker.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/repositories/media/media_repository_impl.dart';
import 'package:cleer/data/services/media/media_service_client.dart';
import 'package:cleer/domain/failures/storage_failures.dart';
import 'package:cleer/domain/models/process_image_result/process_image_result.dart';
import 'package:cleer/domain/use_cases/storage/params/process_image_params.dart';

part 'media_repository.g.dart';

@riverpod
MediaRepository mediaRepository(Ref ref) => MediaRepositoryImpl(
  mediaServiceClient: ref.watch(mediaServiceClientProvider),
);

abstract class MediaRepository {
  Future<ResultDart<XFile, StorageFailure>> pickImageFromGallery();
  // Future<ResultDart<List<XFile>, StorageFailure>> pickMultipleImages();
  Future<ResultDart<ProcessImageDomainResult, StorageFailure>> processImage(
      ProcessImageParams params,
      );
}
