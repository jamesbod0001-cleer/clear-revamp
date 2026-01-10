import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/auth/auth_repository.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/enums/app_auth_status.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_up_params.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/utils/password_generator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_use_case.g.dart';

@riverpod
class AuthUseCase extends _$AuthUseCase {
  late final AuthRepository _authRepository;
  final _secureStorage = const FlutterSecureStorage();

  final _log = AmplifyLogger("AuthUseCase");

  @override
  FutureOr<AuthState> build() {
    _initialiseAuthStatus();
    _listenToAuthStateChanges();
    return AuthState.unknown();
  }

  Future<AuthState> _doSomething() async {
    final identityResult = await _authRepository.getAuthIdentity();
    return await identityResult.fold(
      (identity) {
        _log.info('Current user auth identity: $identity');

        return AuthState.signedIn(identity: identity);
      },
      (onFailure) {
        _log.error('Error getting auth identity: $onFailure');
        if (onFailure is NotAuthorizedServiceException ||
            onFailure is SignedOutException ||
            onFailure is UserNotFoundException ||
            onFailure.toString().contains('revoked')) {
          _log.info(
            'Session is invalid/revoked. Force redirecting to signedOut.',
          );

          /// TODO: Sign out
          // _authRepository.signOut();

          return AuthState.signedOut();
        }
        return AuthState.unknown();
      },
    );
  }

  Future<void> _initialiseAuthStatus() async {
    _log.info('Initialising auth status');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return (await _authRepository.isSignedIn()).fold(
        (isSignedIn) async {
          if (isSignedIn) {
            _log.info('User is signed in');
            return await _doSomething();
          } else {
            _log.info('User is not signed in');
            return AuthState.signedOut();
          }
        },
        (onFailure) {
          _log.error('Error checking if user is signed in', onFailure);
          return AuthState.unknown();
        },
      );
    });
  }

  void _listenToAuthStateChanges() {
    _authRepository.authStatus.listen(
      (AppAuthStatus status) async {
        _log.info('Auth status changed: $status');
        switch (status) {
          case AppAuthStatus.signedIn:
            state = const AsyncValue.loading();
            state = AsyncValue.data(await _doSomething());
            break;
          case AppAuthStatus.signedOut:
            _log.info('User signed out');
            state = AsyncValue.data(AuthState.signedOut());
            break;
          case AppAuthStatus.sessionExpired:
            _log.info('User session expired');
            state = AsyncValue.data(AuthState.sessionExpired());
            break;
          case AppAuthStatus.userDeleted:
            _log.info('User account deleted');
            state = AsyncValue.data(AuthState.userDeleted());
            break;
          case AppAuthStatus.unknown:
            _log.info('Unknown auth status');
            state = AsyncValue.data(AuthState.unknown());
            break;
        }
      },
      onError: (error) {
        _log.error('Error listening to auth status', error);
      },
    );
  }

  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUp(
    SignUpParams params,
  ) async {
    final tempPassword = PasswordGenerator.generateSecureTempPassword();
    _log.info('Attempting to create account for user: ${params.email}');
    await _secureStorage.write(
      key: 'temp_pass_${params.phoneNumber}',
      value: tempPassword,
    );
    final paramsWithPass = params.copyWith(password: tempPassword);
    final result = await _authRepository.signUpUser(paramsWithPass);
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
