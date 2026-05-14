import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_result.freezed.dart';

@freezed
sealed class SignInDomainResult with _$SignInDomainResult {
  /// Represents a successful sign-in where the user is fully authenticated.
  const factory SignInDomainResult.success() = SignInSuccess;

  /// Represents a sign-in attempt that requires confirmation with a code.
  const factory SignInDomainResult.confirmationRequired({
    required String destination,
    required String deliveryMedium,
  }) = SignInConfirmationRequired;

  /// Represents a sign-in attempt that requires the user to set a new password.
  const factory SignInDomainResult.confirmWithNewPassword() =
      SignInConfirmWithNewPassword;

  /// Represents a sign-in attempt that requires handling a custom challenge.
  const factory SignInDomainResult.confirmWithCustomChallenge({
    @Default({}) Map<String, String> parameters,
  }) = SignInConfirmWithCustomChallenge;

  /// Represents a sign-in attempt that requires a password reset.
  const factory SignInDomainResult.resetPassword() = SignInResetPassword;

  const factory SignInDomainResult.confirmWithTotpMfaCode() =
      SignInConfrimWithTotpMfaCode;

  const factory SignInDomainResult.confirmWithSmsMfaCode() =
      SignInConfrimWithSmsMfaCode;

  const factory SignInDomainResult.confirmWithOtpCode() =
      SignInConfrimWithOtpCode;

  /// Represents a sign-in attempt that requires MFA selection.
  const factory SignInDomainResult.continueWithMfaSelection() =
      SignInContinueWithMfaSelection;

  /// Represents a sign-in attempt that requires MFA setup selection.
  const factory SignInDomainResult.continueWithMfaSetupSelection() =
      SignInContinueWithMfaSetupSelection;

  /// Represents a sign-in attempt that requires TOTP setup.
  const factory SignInDomainResult.continueWithTotpSetup() =
      SignInContinueWithTotpSetup;

  /// Represents a sign-in attempt that requires email MFA setup.
  const factory SignInDomainResult.continueWithEmailMfaSetup() =
      SignInContinueWithEmailMfaSetup;
}
