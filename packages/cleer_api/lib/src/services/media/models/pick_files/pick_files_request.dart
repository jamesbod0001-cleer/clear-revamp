import 'package:freezed_annotation/freezed_annotation.dart';

part 'pick_files_request.freezed.dart';

@freezed
abstract class PickFilesRequest with _$PickFilesRequest {
  const factory PickFilesRequest({
    List<String>? allowedExtensions,
    @Default(true) bool allowMultiple,
    int? limit,
  }) = _PickFilesRequest;
}
