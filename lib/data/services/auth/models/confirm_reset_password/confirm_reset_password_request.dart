import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_reset_password_request.freezed.dart';

@freezed
abstract class ConfirmResetPasswordRequest with _$ConfirmResetPasswordRequest {
  const factory ConfirmResetPasswordRequest({
    /// Username
    required String username,

    /// New Password
    required String newPassword,

    /// Confirmation code
    required String confirmationCode,
  }) = _ConfirmResetPasswordRequest;
}
