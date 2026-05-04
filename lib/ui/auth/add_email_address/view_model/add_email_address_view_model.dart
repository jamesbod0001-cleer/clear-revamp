import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/update_user_attribute_result/update_user_attribute_result.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_email_address_view_model.g.dart';

@riverpod
class AddEmailAddressViewModel extends _$AddEmailAddressViewModel {
  final _log = AmplifyLogger('AddEmailAddressViewModel');

  @override
  FutureOr<UpdateUserAttributeDomainResult?> build() {
    return null;
  }

  Future<void> addEmailAddress(String email) async {
    _log.info('Attempting to add email address');
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authUseCaseProvider.notifier)
          .updateEmail(email);
      return result.fold(
        (result) {
          _log.info('Successfully added email address');
          return result;
        },
        (failure) {
          _log.error('Error adding email address', failure);
          throw failure;
        },
      );
    });
  }
}
