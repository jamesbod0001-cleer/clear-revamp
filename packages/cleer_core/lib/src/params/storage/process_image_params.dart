import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_image_params.freezed.dart';

@freezed
abstract class ProcessImageParams with _$ProcessImageParams {
  const factory ProcessImageParams({
    required File originalFile,
    required int width,
    required int height,
    @Default(80) int quality,
  }) = _ProcessImageParams;
}
