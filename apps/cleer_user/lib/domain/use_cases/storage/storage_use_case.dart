import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/process_image_result/process_image_result.dart';
import 'package:cleer_core/models/upload_image_result/upload_image_result.dart';

part 'storage_use_case.g.dart';

@Riverpod(keepAlive: true)
class StorageUseCase extends _$StorageUseCase {
  late final StorageRepository _storageRepository;
  late final MediaRepository _mediaRepository;

  final _log = AmplifyLogger("StorageUseCase");

  final Map<String, (Uri url, DateTime expiry)> _urlCache = {};

  @override
  void build() {
    ref.watch(userProfileProvider.select((user) => user.value?.id));

    _storageRepository = ref.watch(storageRepositoryProvider);
    _mediaRepository = ref.watch(mediaRepositoryProvider);
  }

  /// Fetches a temporary signed URL for an S3 Key with memory caching
  Future<ResultDart<Uri, StorageFailure>> getUrl(String key) async {
    if (_urlCache.containsKey(key)) {
      final (cachedUrl, expiry) = _urlCache[key]!;
      if (DateTime.now().isBefore(
        expiry.subtract(const Duration(minutes: 5)),
      )) {
        return Success(cachedUrl);
      }
    }

    _log.info("Fetching fresh signed URL for: $key");
    final result = await _storageRepository.getUrl(key);

    return result.fold((url) {
      _urlCache[key] = (url, DateTime.now().add(const Duration(days: 7)));
      return Success(url);
    }, (failure) => Failure(failure));
  }

  Future<ResultDart<XFile, StorageFailure>> pickImage() async {
    _log.info("Picking image");
    final result = await _mediaRepository.pickImageFromGallery();
    result.fold(
      (imageFile) => _log.info("Image picked: ${imageFile.path}"),
      (failure) => _log.error("Error picking image", failure),
    );
    return result;
  }

  Future<ResultDart<List<XFile>, StorageFailure>> pickMultipleImages(
    int? limit,
  ) async {
    _log.info("Picking multiple images");
    final result = await _mediaRepository.pickMultipleImages(limit);
    result.fold(
      (imageFile) => _log.info("Picked ${imageFile.length} images"),
      (failure) => _log.error("Error picking images", failure),
    );
    return result;
  }

  Future<ResultDart<ProcessImageDomainResult, StorageFailure>> processImage(
    ProcessImageParams params,
  ) async {
    _log.info("Processing image");
    final ResultDart<ProcessImageDomainResult, StorageFailure> result =
        await _mediaRepository.processImage(params);
    result.fold(
      ((success) => _log.info("Image processed")),
      (failure) => _log.error("Error processing image", failure),
    );
    return result;
  }

  Future<ResultDart<UploadImageResult, Object>> uploadImage({
    required ProcessImageDomainResult processedImageResult,
    required String fullPath,
    String? altText,
    void Function(double)? onProgress,
  }) async {
    _log.info("Uploading image");

    final result = await _storageRepository.uploadFile(
      UploadFileParams(
        file: processedImageResult.file,
        path: fullPath,
        onProgress: onProgress,
      ),
    );

    return result.fold(
      (key) {
        _log.info("Image uploaded $key");
        return Success(
          UploadImageResult.fromProcess(
            key: key,
            processed: processedImageResult,
            altText: altText ?? fullPath.split('/').last,
          ),
        );
      },
      (onFailure) {
        _log.error("Error uploading image", onFailure);
        throw onFailure;
      },
    );
  }

  Future<ResultDart<String, StorageFailure>> deleteFile(String key) async {
    _log.info("Deleting files");
    final result = await _storageRepository.deleteFile(key);
    result.fold((success) {
      _log.info("Files deleted");
      if (_urlCache.containsKey(key)) {
        _urlCache.remove(key);
        _log.info("Cached URL removed");
      }
    }, (failure) => _log.error("Error deleting files", failure));
    return result;
  }
}
