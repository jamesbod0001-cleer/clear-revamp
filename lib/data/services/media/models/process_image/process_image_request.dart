import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_image_request.freezed.dart';

@freezed
abstract class ProcessImageRequest with _$ProcessImageRequest {
  const factory ProcessImageRequest({
    required File originalFile,
    required int width,
    required int height,
    @Default(80) int quality,
  }) = _ProcessImageRequest;
}
