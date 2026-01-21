import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_reset_password_params.dart';
import 'package:cleer/ui/auth/forgot_password/state/forgot_password_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forgot_password_view_model.g.dart';

@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  final _log = AmplifyLogger("ForgotPasswordViewModel");

  @override
  FutureOr<ForgotPasswordState> build() {
    return ForgotPasswordState(
      forgotPasswordFormData: ForgotPasswordFormData.empty(),
    );
  }

  Future<void> requestCode() async {
    _log.info('Attempting to request code');
    final formData = state.value!.forgotPasswordFormData;
    final isEmailMode = state.value!.isEmailMode;
    final cleanDigits = formData.phoneNumber.replaceAll(' ', '');
    final fullE164Number = '+234$cleanDigits';

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .resetPassword(isEmailMode ? formData.email : fullE164Number);
      return result.fold(
        (result) {
          _log.info('Reset password result: $result');
          return state.value!.copyWith(
            resetPasswordDomainResult: result,
            forgotPasswordStep: ForgotPasswordStep.resetPassword,
          );
        },
        (failure) {
          _log.error('Reset password failure: $failure');
          throw failure;
        },
      );
    });
  }

  Future<void> resetPassword() async {
    _log.info('Attempting to reset password');
    final formData = state.value!.forgotPasswordFormData;
    final isEmailMode = state.value!.isEmailMode;

    final cleanDigits = formData.phoneNumber.replaceAll(' ', '');
    final fullE164Number = '+234$cleanDigits';

    final String username = isEmailMode ? formData.email : fullE164Number;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .confirmResetPassword(
            ConfirmResetPasswordParams(
              username: username,
              newPassword: state.value!.forgotPasswordFormData.newPassword,
              confirmationCode: state.value!.forgotPasswordFormData.code,
            ),
          );
      return result.fold(
        (result) {
          _log.info('Confirm reset password result: $result');
          return state.value!.copyWith(resetPasswordDomainResult: result);
        },
        (failure) {
          _log.error('Confirm reset password failure: $failure');
          throw failure;
        },
      );
    });
  }

  void toggleIsEmailMode() {
    final currentState = state.value!;
    state = AsyncData(
      currentState.copyWith(
        isEmailMode: !currentState.isEmailMode,
        forgotPasswordFormData: currentState.forgotPasswordFormData.copyWith(
          phoneNumber: '',
          email: '',
        ),
      ),
    );
  }

  void moveStepBack() {
    final forgotPasswordState = state.value;
    if (forgotPasswordState == null) return;

    final currentStep = forgotPasswordState.forgotPasswordStep;

    if (currentStep != ForgotPasswordStep.requestCode) {
      final previousStep = ForgotPasswordStep.values[currentStep.index - 1];
      state = AsyncValue.data(
        forgotPasswordState.copyWith(
          forgotPasswordStep: previousStep,
          resetPasswordDomainResult: null,
          forgotPasswordFormData: state.value!.forgotPasswordFormData.copyWith(
            code: '',
            newPassword: '',
          ),
        ),
      );
    }
  }

  void onFormChanged(ForgotPasswordFormData formData) {
    if (state.hasValue) {
      _log.debug('Forgot password form changed: $formData');
      state = AsyncValue.data(
        state.value!.copyWith(forgotPasswordFormData: formData),
      );
    }
  }
}
