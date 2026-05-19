import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'upload_file_request.freezed.dart';

@freezed
abstract class UploadFileRequest with _$UploadFileRequest {
  const factory UploadFileRequest({
    required XFile file,
    required String path,
    Function(double)? onProgress,
  }) = _UploadFileRequest;
}
