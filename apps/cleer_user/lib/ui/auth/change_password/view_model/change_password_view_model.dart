import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer_core/models/update_password_result/update_password_result.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/utils/snack_bar_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_password_view_model.g.dart';

@riverpod
class ChangePasswordViewModel extends _$ChangePasswordViewModel {
  final _log = AmplifyLogger("ChangePasswordViewModel");

  @override
  FutureOr<UpdatePasswordDomainResult?> build() {
    return null;
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _log.info('Attempting to change password for user');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .updatePassword(
            UpdatePasswordParams(
              oldPassword: oldPassword,
              newPassword: newPassword,
            ),
          );
      return await result.fold(
        (result) {
          _log.info('Password changed successfully for user');
          SnackBarHelper.showSuccess('Password updated successfully');
          return result;
        },
        (onFailure) {
          _log.error('Error creating password for user', onFailure);
          throw onFailure;
        },
      );
    });
  }
}
