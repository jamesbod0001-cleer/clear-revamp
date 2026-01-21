import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_in_params.dart';
import 'package:cleer/ui/auth/login/state/login_state.dart';
import 'package:cleer/utils/validators/validators.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  final _log = AmplifyLogger("LoginViewModel");

  @override
  FutureOr<LoginState> build() {
    return LoginState(loginFormData: LoginFormData.empty());
  }

  Future<void> login() async {
    _log.info('Attempting to login');
    final formData = state.value!.loginFormData;
    final isEmailMode = state.value!.isEmailMode;

    final cleanDigits = formData.phoneNumber.replaceAll(' ', '');
    final fullE164Number = '+234$cleanDigits';
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .signIn(
            SignInParams(
              username: isEmailMode ? formData.email : fullE164Number,
              password: formData.password,
            ),
          );
      return result.fold(
        (result) {
          _log.info('Successfully logged in');
          return state.value!.copyWith(signInDomainResult: result);
        },
        (failure) {
          _log.error('Error logging in', failure);
          throw failure;
        },
      );
    });
  }

  void onFormChanged(LoginFormData formData) {
    if (state.hasValue) {
      _log.debug('Login form changed: $formData');
      state = AsyncValue.data(state.value!.copyWith(loginFormData: formData));
    }
  }

  void toggleLoginMode() {
    final currentState = state.value!;
    state = AsyncData(
      currentState.copyWith(
        isEmailMode: !currentState.isEmailMode,
        loginFormData: currentState.loginFormData.copyWith(
          phoneNumber: '',
          email: '',
        ),
      ),
    );
  }

  void resetResult() {
    state = AsyncValue.data(state.value!.copyWith(signInDomainResult: null));
  }
}

extension LoginFormDataExtension on LoginState {
  bool get isFormValid =>
      (isEmailMode
          ? loginFormData.email.isValidEmailRequired
          : loginFormData.phoneNumber.isValidPhone) &&
      loginFormData.password.isNotEmpty;
  // && loginFormData.password.isValidPassword;
}
