import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/user/user_use_case.dart';
import 'package:command_it/command_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_security_view_model.g.dart';

@Riverpod(keepAlive: true)
class AccountSecurityViewModel extends _$AccountSecurityViewModel {
  final _log = AmplifyLogger("AccountSecurityViewModel");

  @override
  FutureOr<void> build() async {
    uploadProfilePicture = Command.createAsyncNoParamNoResult(
      _uploadProfilePicture,
      errorFilter: const LocalErrorFilter(),
    );
  }

  late Command<void, void> uploadProfilePicture;

  Future<void> _uploadProfilePicture() async {
    final result = await ref
        .read(userUseCaseProvider.notifier)
        .pickAndUploadProfilePicture();

    return result.fold((success) => _log.info('Upload complete'), (failure) {
      _log.error('Upload failed', failure);
      throw failure;
    });
  }
}
