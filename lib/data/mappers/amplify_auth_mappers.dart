import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';

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
