import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'process_image_result.freezed.dart';

@freezed
abstract class ProcessImageResult with _$ProcessImageResult {
  const factory ProcessImageResult({
    required XFile file,
    required String blurHash,
    required int width,
    required int height,
    required int fileSize,
  }) = _ProcessImageResult;
}
