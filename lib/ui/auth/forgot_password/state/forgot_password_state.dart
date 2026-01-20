import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cleer/domain/models/reset_password_result/reset_password_result.dart';

part 'forgot_password_state.freezed.dart';

enum ForgotPasswordStep { requestCode, resetPassword }

@freezed
abstract class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    required ForgotPasswordFormData forgotPasswordFormData,
    ResetPasswordDomainResult? resetPasswordDomainResult,
    @Default(ForgotPasswordStep.requestCode)
    ForgotPasswordStep forgotPasswordStep,
  }) = _ForgotPasswordState;
}

@freezed
abstract class ForgotPasswordFormData with _$ForgotPasswordFormData {
  const factory ForgotPasswordFormData({
    @Default('') String phoneNumber,
    @Default('') String email,
    @Default('') String code,
    @Default('') String newPassword,
  }) = _ForgotPasswordFormData;

  factory ForgotPasswordFormData.empty() => const ForgotPasswordFormData();
}
