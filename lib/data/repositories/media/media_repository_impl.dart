import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer/data/amplify_exceptions/amplify_storage_exception_handler.dart';
import 'package:cleer/data/mappers/media_mappers.dart';
import 'package:cleer/data/repositories/media/media_repository.dart';
import 'package:cleer/data/services/media/media_service_client.dart';
import 'package:cleer/data/services/media/models/process_image/process_image_request.dart';
import 'package:cleer/domain/failures/storage_failures.dart';
import 'package:cleer/domain/models/process_image_result/process_image_result.dart';
import 'package:cleer/domain/use_cases/storage/params/process_image_params.dart';

class MediaRepositoryImpl extends MediaRepository {
  final MediaServiceClient _mediaServiceClient;

  MediaRepositoryImpl({required MediaServiceClient mediaServiceClient})
      : _mediaServiceClient = mediaServiceClient;

  final _log = AmplifyLogger('MediaRepositoryImpl');

  @override
  Future<ResultDart<XFile, StorageFailure>> pickImageFromGallery() async {
    _log.info('Picking image from gallery');
    try {
      final imageFile = await _mediaServiceClient.pickImageFromGallery();
      if (imageFile == null) {
        _log.error('Error picking image from gallery, user canceled');
        return Failure(StorageFailure.canceled());
      } else {
        _log.info('Successfully picked image from gallery');
        return Success(imageFile);
      }
    } catch (e) {
      _log.error('Error picking image from gallery: $e');
      return Failure(AmplifyStorageExceptionHandler.handleGenericException(e));
    }
  }

  @override
  Future<ResultDart<ProcessImageDomainResult, StorageFailure>> processImage(
      ProcessImageParams params,
      ) async {
    try {
      _log.info('Processing image');
      final result = await _mediaServiceClient.processImage(
        ProcessImageRequest(
          originalFile: params.originalFile,
          width: params.width,
          height: params.height,
          quality: params.quality,
        ),
      );
      return Success(result.toDomain());
    } catch (e) {
      _log.error('Error processing image: $e');
      return Failure(AmplifyStorageExceptionHandler.handleGenericException(e));
    }
  }

  // @override
  // Future<ResultDart<List<XFile>, StorageFailure>> pickMultipleImages() async {
  //   try {
  //     final imageFiles = await _mediaServiceClient.pickMultipleImages();
  //     if (imageFiles.isEmpty) {
  //       _log.error('No image picked from gallery');
  //       return Failure(StorageFailure.canceled());
  //     } else {
  //       _log.info(
  //         'Successfully picked ${imageFiles.length} images from gallery',
  //       );
  //       return Success(imageFiles);
  //     }
  //   } catch (e) {
  //     _log.error('Error picking images from gallery: $e');
  //     return Failure(AmplifyStorageExceptionHandler.handleGenericException(e));
  //   }
  // }
}
