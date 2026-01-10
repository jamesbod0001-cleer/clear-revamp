import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/auth_identity/auth_identity.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:collection/collection.dart';

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
