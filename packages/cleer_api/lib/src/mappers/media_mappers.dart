import 'package:cleer_api/src/services/media/models/process_image/process_image_result.dart';
import 'package:cleer_core/models/process_image_result/process_image_result.dart';

extension ProcessImageResultToDomain on ProcessImageResult {
  ProcessImageDomainResult toDomain() {
    return ProcessImageDomainResult(
      file: file,
      blurHash: blurHash,
      width: width,
      height: height,
      fileSize: fileSize,
    );
  }
}
