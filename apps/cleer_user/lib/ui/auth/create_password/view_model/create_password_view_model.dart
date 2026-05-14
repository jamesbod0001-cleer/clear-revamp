import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_password_view_model.g.dart';

@riverpod
class CreatePasswordViewModel extends _$CreatePasswordViewModel {
  final _log = AmplifyLogger("CreatePasswordViewModel");

  @override
  FutureOr<void> build() {}

  Future<void> createPassword({
    required String phoneNumber,
    required String password,
  }) async {
    _log.info('Attempting to create password for user: $phoneNumber');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .confirmSignUpAndSetPassword(
            phoneNumber: phoneNumber,
            password: password,
          );
      return await result.fold(
        (onSuccess) {
          _log.info('Password created successfully for user: $phoneNumber');
        },
        (onFailure) {
          _log.error(
            'Error creating password for user: $phoneNumber',
            onFailure,
          );
          throw onFailure;
        },
      );
    });
  }
}
