import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo.freezed.dart';

@freezed
abstract class Photo with _$Photo {
  const factory Photo({
    required String key,
    String? blurHash,
    int? width,
    int? height,
    String? altText,
  }) = _Photo;
}
