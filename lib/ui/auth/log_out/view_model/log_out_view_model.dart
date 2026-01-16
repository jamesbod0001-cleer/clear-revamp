import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'log_out_view_model.g.dart';

@riverpod
class LogOutViewModel extends _$LogOutViewModel {
  final _log = AmplifyLogger("LogOutViewModel");

  @override
  Future<void> build() async {}

  Future<void> logOut() async {
    _log.info("logging out...");
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      (await ref.read(authUseCaseProvider.notifier).signOut()).fold(
            (onSuccess) {
          _log.info("Log out successful");
        },
            (onFailure) {
          _log.warn("Log out failed");
          throw onFailure;
        },
      );
    });
  }
}
