import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/code_delivery_details/code_delivery_details.dart';
import 'package:cleer/domain/models/update_user_attribute_result/update_user_attribute_result.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/ui/auth/verify_email_address/state/verify_email_address_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_email_address_view_model.g.dart';

@riverpod
class VerifyEmailAddressViewModel extends _$VerifyEmailAddressViewModel {
  final _log = AmplifyLogger('VerifyEmailAddressViewModel');

  @override
  FutureOr<VerifyEmailAddressState> build() async {
    final sendEmailVerificationCodeResult = await ref
        .read(authUseCaseProvider.notifier)
        .sendEmailVerificationCode();
    return sendEmailVerificationCodeResult.fold(
      (codeDeliveryDetails) {
        return VerifyEmailAddressState(
          codeDeliveryDetails: codeDeliveryDetails,
        );
      },
      (failure) {
        throw failure;
      },
    );
  }

  Future<void> verifyEmailAddress(String code) async {
    _log.info('Attempting to verify email address');
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .confirmEmailVerificationCode(code);
      return result.fold(
        (result) {
          _log.info('Successfully verified email address');
          return state.value!.copyWith(
            confirmUserAttributeDomainResult: result,
          );
        },
        (failure) {
          _log.error('Error verifying email address', failure);
          throw failure;
        },
      );
    });
  }

  Future<void> resendCode() async {
    _log.info('Attempting to resend code to user');
    (await ref.read(authUseCaseProvider.notifier).sendEmailVerificationCode())
        .fold(
          (codeDeliveryDetails) {
            _log.info('Successfully resent code to user: $codeDeliveryDetails');
          },
          (failure) {
            _log.error('Error resending code to user', failure);
            throw failure;
          },
        );
  }


  Future<void> changeEmail(String newEmail) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .changeEmail(newEmail);

      return result.fold(
        (domainResult) {
          _log.info('Successfully changed email address');
          VerifyEmailAddressState newState = state.value!.copyWith(
            updateUserAttributeDomainResult: domainResult,
          );
          domainResult.when(
            success: () {
              _log.info('Email has successfully been confirmed without a code');
            },
            confirmationRequired: (destination, deliveryMedium) {
              _log.info('Updating UI to show new destination: $destination');
              newState = newState.copyWith(
                codeDeliveryDetails: CodeDeliveryDetails(
                  destination: destination,
                  deliveryMedium: deliveryMedium,
                ),
              );
            },
          );
          return newState;
        },
        (failure) {
          _log.error('Error changing email address', failure);
          throw failure;
        },
      );
    });
  }
}
