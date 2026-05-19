import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'upload_file_params.freezed.dart';

@freezed
abstract class UploadFileParams with _$UploadFileParams {
  const factory UploadFileParams({
    required XFile file,
    required String path,
    Function(double)? onProgress,
  }) = _UploadFileParams;
}
