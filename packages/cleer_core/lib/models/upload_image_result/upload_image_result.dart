import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cleer_core/models/photo/photo.dart';
import 'package:cleer_core/models/process_image_result/process_image_result.dart';

part 'upload_image_result.freezed.dart';

@freezed
abstract class UploadImageResult with _$UploadImageResult {
  const factory UploadImageResult({
    required String key,
    required String blurHash,
    required int width,
    required int height,
    required String altText,
  }) = _UploadImageResult;

  /// Factory to convert a Process result and an S3 Key into this result
  factory UploadImageResult.fromProcess({
    required String key,
    required ProcessImageDomainResult processed,
    required String altText,
  }) {
    return UploadImageResult(
      key: key,
      blurHash: processed.blurHash,
      width: processed.width,
      height: processed.height,
      altText: altText,
    );
  }
}

extension UploadImageResultX on UploadImageResult {
  Photo toPhoto() {
    return Photo(key: key, blurHash: blurHash, width: width, height: height);
  }
}
