import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_file_request.freezed.dart';

@freezed
abstract class UploadFileRequest with _$UploadFileRequest {
  const factory UploadFileRequest({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) = _UploadFileRequest;
}
