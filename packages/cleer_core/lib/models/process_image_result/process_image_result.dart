import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_image_result.freezed.dart';

@freezed
abstract class ProcessImageDomainResult with _$ProcessImageDomainResult {
  const factory ProcessImageDomainResult({
    required File file,
    required String blurHash,
    required int width,
    required int height,
    required int fileSize,
  }) = _ProcessImageDomainResult;
}
