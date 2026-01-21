import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_password_request.freezed.dart';

@freezed
abstract class UpdatePasswordRequest with _$UpdatePasswordRequest {
  const factory UpdatePasswordRequest({
    /// Plain Text Old Password
    required String oldPassword,

    /// Plain Text New Password
    required String newPassword,
  }) = _UpdatePasswordRequest;
}
