import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/repositories/auth/auth_repository.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_up_params.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_use_case.g.dart';

@riverpod
class AuthUseCase extends _$AuthUseCase {
  late final AuthRepository _authRepository;

  final _log = AmplifyLogger("AuthUseCase");

  @override
  FutureOr<AuthState> build() {
    return AuthState.unknown();
  }

  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUp(
    SignUpParams params,
  ) async {
    _log.info('Attempting to create account for user: ${params.email}');
    final result = await _authRepository.signUpUser(params);
    result.fold(
      (success) {
        _log.info('Successfully created account for user: ${params.email}');
      },
      (failure) {
        _log.error('Error creating account for user: ${params.email}', failure);
      },
    );
    return result;
  }
}
