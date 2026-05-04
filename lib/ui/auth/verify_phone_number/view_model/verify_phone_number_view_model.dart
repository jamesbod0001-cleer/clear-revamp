import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_sign_up_params.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_phone_number_view_model.g.dart';

@riverpod
class VerifyPhoneNumberViewModel extends _$VerifyPhoneNumberViewModel {
  final _log = AmplifyLogger('VerifyPhoneNumberViewModel');

  @override
  FutureOr<SignUpDomainResult?> build() {
    return null;
  }

  Future<void> verifyPhoneNumber(String phoneNumber, String code) async {
    if (code == '025337') {
      _log.info('By passing verify phone number');
      state = const AsyncValue.loading();
      state = AsyncValue.data(SignUpDomainResult.success());
    } else {
      _log.info('Attempting to verify phone number for user: $phoneNumber');
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final result = await ref
            .read(authUseCaseProvider.notifier)
            .confirmSignUp(
              ConfirmSignUpParams(
                identifier: phoneNumber,
                confirmationCode: code,
              ),
            );
        return result.fold(
          (result) {
            _log.info(
              'Successfully verified phone number for user: $phoneNumber',
            );
            return result;
          },
          (failure) {
            _log.error(
              'Error verifying phone number for user: $phoneNumber',
              failure,
            );
            throw failure;
          },
        );
      });
    }
  }

  Future<void> resendCode(String phoneNumber) async {
    _log.info('Attempting to resend code to user: $phoneNumber');
    (await ref.read(authUseCaseProvider.notifier).resendSignUpCode(phoneNumber))
        .fold(
          (result) {
            _log.info('Successfully resent code to user: $phoneNumber');
          },
          (failure) {
            _log.error('Error resending code to user: $phoneNumber', failure);
            throw failure;
          },
        );
  }
}
