import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/auth_identity/auth_identity.dart';
import 'package:cleer/domain/models/code_delivery_details/code_delivery_details.dart';
import 'package:cleer/domain/models/reset_password_result/reset_password_result.dart';
import 'package:cleer/domain/models/sign_in_result/sign_in_result.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/models/update_password_result/update_password_result.dart';
import 'package:cleer/utils/constants.dart';
import 'package:collection/collection.dart';

extension AuthCodeDeliveryDetailsMapper on AuthCodeDeliveryDetails {
  CodeDeliveryDetails toDomain() {
    return CodeDeliveryDetails(
      destination: destination,
      deliveryMedium: deliveryMedium.name,
    );
  }
}

extension SignInMapper on SignInResult {
  SignInDomainResult toDomain() {
    final codeDeliveryDetails = nextStep.codeDeliveryDetails;
    final parameters = nextStep.additionalInfo;

    switch (nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithSmsMfaCode:
        return const SignInDomainResult.confirmWithSmsMfaCode();
      case AuthSignInStep.confirmSignInWithTotpMfaCode:
        return const SignInDomainResult.confirmWithTotpMfaCode();
      case AuthSignInStep.confirmSignInWithOtpCode:
        return const SignInDomainResult.confirmWithOtpCode();
      case AuthSignInStep.confirmSignUp:
        return SignInDomainResult.confirmationRequired(
          destination:
              codeDeliveryDetails?.destination ?? 'Unknown destination',
          deliveryMedium: codeDeliveryDetails?.deliveryMedium.name ?? kEmpty,
        );
      case AuthSignInStep.confirmSignInWithNewPassword:
        return const SignInDomainResult.confirmWithNewPassword();
      case AuthSignInStep.confirmSignInWithCustomChallenge:
        return SignInDomainResult.confirmWithCustomChallenge(
          parameters: parameters,
        );
      case AuthSignInStep.resetPassword:
        return const SignInDomainResult.resetPassword();
      case AuthSignInStep.done:
        return const SignInDomainResult.success();
      case AuthSignInStep.continueSignInWithMfaSelection:
        return const SignInDomainResult.continueWithMfaSelection();
      case AuthSignInStep.continueSignInWithMfaSetupSelection:
        return const SignInDomainResult.continueWithMfaSetupSelection();
      case AuthSignInStep.continueSignInWithTotpSetup:
        return const SignInDomainResult.continueWithTotpSetup();
      case AuthSignInStep.continueSignInWithEmailMfaSetup:
        return const SignInDomainResult.continueWithEmailMfaSetup();
    }
  }
}

extension AuthMapper on SignUpResult {
  SignUpDomainResult toDomain() {
    switch (nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final deliveryDetails = nextStep.codeDeliveryDetails!;
        return SignUpDomainResult.confirmationRequired(
          destination: deliveryDetails.destination ?? 'Unknown destination',
          deliveryMedium: deliveryDetails.deliveryMedium.name,
        );
      case AuthSignUpStep.done:
        return const SignUpDomainResult.success();
    }
  }
}

extension ResetPasswordMapper on ResetPasswordResult {
  ResetPasswordDomainResult toDomain() {
    switch (nextStep.updateStep) {
      case AuthResetPasswordStep.confirmResetPasswordWithCode:
        final deliveryDetails = nextStep.codeDeliveryDetails!;
        return ResetPasswordDomainResult.confirmationRequired(
          destination: deliveryDetails.destination ?? 'Unknown destination',
          deliveryMedium: deliveryDetails.deliveryMedium.name,
        );
      case AuthResetPasswordStep.done:
        return const ResetPasswordDomainResult.success();
    }
  }
}

extension UpdatePasswordMapper on UpdatePasswordResult {
  UpdatePasswordDomainResult toDomain() {
    return UpdatePasswordDomainResult.success();
  }
}

extension UserAttributeExtractor on List<AuthUserAttribute> {
  AuthIdentity toDomain() {
    String sub = firstWhere(
      (element) => element.userAttributeKey == CognitoUserAttributeKey.sub,
      orElse: () => throw Exception('Sub attribute not found'),
    ).value;

    String firstName = firstWhere(
      (attr) => attr.userAttributeKey == AuthUserAttributeKey.givenName,
      orElse: () => throw Exception('First name attribute not found'),
    ).value;

    String lastName = firstWhere(
      (attr) => attr.userAttributeKey == AuthUserAttributeKey.familyName,
      orElse: () => throw Exception('Last name attribute not found'),
    ).value;

    String phoneNumber = firstWhere(
      (attr) => attr.userAttributeKey == AuthUserAttributeKey.phoneNumber,
      orElse: () => throw Exception('Phone number attribute not found'),
    ).value;

    String? email = firstWhereOrNull(
      (attr) => attr.userAttributeKey == AuthUserAttributeKey.email,
    )?.value;

    return AuthIdentity(
      id: sub,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
    );
  }
}
