import 'package:freezed_annotation/freezed_annotation.dart';

part 'pick_files_params.freezed.dart';

@freezed
abstract class PickFilesParams with _$PickFilesParams {
  const factory PickFilesParams({
    List<String>? allowedExtensions,
    @Default(true) bool allowMultiple,
    int? limit,
  }) = _PickFilesParams;
}
