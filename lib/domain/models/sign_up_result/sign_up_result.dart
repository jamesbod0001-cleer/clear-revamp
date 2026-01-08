import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_result.freezed.dart';

@freezed
sealed class SignUpDomainResult with _$SignUpDomainResult {
  /// Represents a successful sign-up where the user is fully confirmed and can sign in.
  const factory SignUpDomainResult.success() = SignUpSuccess;

  /// Represents a successful sign-up, but the user needs to confirm their account.
  /// It provides details about where the confirmation code was sent.
  const factory SignUpDomainResult.confirmationRequired({
    required String destination,
    required String deliveryMedium,
  }) = SignUpConfirmationRequired;
}
