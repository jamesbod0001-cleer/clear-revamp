import 'package:cleer_core/models/process_image_result/process_image_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_package_photos_state.freezed.dart';

@freezed
abstract class UploadPackagePhotosState with _$UploadPackagePhotosState {
  const factory UploadPackagePhotosState({
    @Default([]) List<ProcessImageDomainResult> selectedImages,
  }) = _UploadPackagePhotosState;
}
