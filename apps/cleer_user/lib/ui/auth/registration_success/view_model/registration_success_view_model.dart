import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_success_view_model.g.dart';

@riverpod
class RegistrationSuccessViewModel extends _$RegistrationSuccessViewModel {
  final _log = AmplifyLogger("RegistrationSuccessViewModel");

  @override
  void build() {}

  void finish() {
    _log.info('Finishing registration');
    ref.read(authUseCaseProvider.notifier).completeOnboarding();
  }
}
