import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/ui/auth/create_account/state/create_account_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_account_view_model.g.dart';

@riverpod
class CreateAccountViewModel extends _$CreateAccountViewModel {
  final _log = AmplifyLogger("CreateAccountViewModel");

  @override
  FutureOr<CreateAccountState> build() {
    return CreateAccountState(
      createAccountFormData: CreateAccountFormData.empty(),
    );
  }

  Future<void> signUp() async {
    _log.info('Attempting to create account');
    final formData = state.value!.createAccountFormData;

    final cleanDigits = formData.phoneNumber.replaceAll(' ', '');
    final fullE164Number = '+234$cleanDigits';
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .signUp(
            SignUpParams(
              firstName: formData.firstName,
              lastName: formData.lastName,
              phoneNumber: fullE164Number,
              email: formData.email,
            ),
          );
      return result.fold(
        (result) {
          _log.info('Successfully created account');
          return state.value!.copyWith(signUpDomainResult: result);
        },
        (failure) {
          _log.error('Error creating account', failure);
          throw failure;
        },
      );
    });
  }

  void onFormChanged(CreateAccountFormData formData) {
    if (state.hasValue) {
      _log.debug('Create account form changed: $formData');
      state = AsyncValue.data(
        state.value!.copyWith(createAccountFormData: formData),
      );
    }
  }

  void resetResult() {
    state = AsyncValue.data(state.value!.copyWith(signUpDomainResult: null));
  }
}

extension CreateAccountFormDataExtension on CreateAccountFormData {
  bool get isValid =>
      firstName.isValidName &&
      lastName.isValidName &&
      email.isValidEmailOptional &&
      phoneNumber.isValidPhone;
}
