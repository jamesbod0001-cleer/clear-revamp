import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_image_result.freezed.dart';

@freezed
abstract class ProcessImageResult with _$ProcessImageResult {
  const factory ProcessImageResult({
    required File file,
    required String blurHash,
    required int width,
    required int height,
    required int fileSize,
  }) = _ProcessImageResult;
}
