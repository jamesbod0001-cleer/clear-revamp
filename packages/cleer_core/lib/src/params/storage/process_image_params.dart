import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'process_image_params.freezed.dart';

@freezed
abstract class ProcessImageParams with _$ProcessImageParams {
  const factory ProcessImageParams({
    required XFile originalFile,
    required int width,
    required int height,
    @Default(80) int quality,
  }) = _ProcessImageParams;
}
