import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_password_result.freezed.dart';

@freezed
sealed class ResetPasswordDomainResult with _$ResetPasswordDomainResult {
  const factory ResetPasswordDomainResult.success() = ResetPasswordSuccess;

  const factory ResetPasswordDomainResult.confirmationRequired({
    required String destination,
    required String deliveryMedium,
  }) = ResetPasswordConfirmationRequired;
}
