import 'package:cleer/data/services/media/models/process_image/process_image_result.dart';
import 'package:cleer/domain/models/process_image_result/process_image_result.dart';

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
