import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_reset_password_params.freezed.dart';

@freezed
abstract class ConfirmResetPasswordParams with _$ConfirmResetPasswordParams {
  const factory ConfirmResetPasswordParams({
    required String identifier,
    required String newPassword,
    required String confirmationCode,
  }) = _ConfirmResetPasswordParams;
}
