import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_file_params.freezed.dart';

@freezed
abstract class UploadFileParams with _$UploadFileParams {
  const factory UploadFileParams({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) = _UploadFileParams;
}
