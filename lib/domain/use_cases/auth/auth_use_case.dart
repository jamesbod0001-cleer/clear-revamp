import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/user/user_repository.dart';
import 'package:cleer/data/repositories/auth/auth_repository.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/enums/app_auth_status.dart';
import 'package:cleer/domain/models/reset_password_result/reset_password_result.dart';
import 'package:cleer/domain/models/sign_in_result/sign_in_result.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/models/update_password_result/update_password_result.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_reset_password_params.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_sign_up_params.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_in_params.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_up_params.dart';
import 'package:cleer/domain/use_cases/auth/params/update_password_params.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/utils/password_generator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_use_case.g.dart';

@riverpod
class AuthUseCase extends _$AuthUseCase {
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  final _secureStorage = const FlutterSecureStorage();
  bool _isProcessingRegistration = false;

  final _log = AmplifyLogger("AuthUseCase");

  @override
  FutureOr<AuthState> build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _initialiseAuthStatus();
    _listenToAuthStateChanges();
    return AuthState.unknown();
  }

  Future<AuthState> _syncUserProfile({
    bool isCompilingRegistration = false,
  }) async {
    final identityResult = await _authRepository.getAuthIdentity();
    return await identityResult.fold(
      (identity) async {
        _log.info('Current user auth identity: $identity');
        final syncResult = await _userRepository.getOrCreateUserProfile(
          User(
            id: identity.id,
            firstName: identity.firstName,
            lastName: identity.lastName,
            phoneNumber: identity.phoneNumber,
            email: identity.email,
          ),
        );
        return syncResult.fold(
          (user) {
            _log.info('Successfully synced user profile');
            return AuthState.signedIn(
              identity: identity,
              isRegistrationComplete: !isCompilingRegistration,
            );
          },
          (failure) {
            _log.error('Error syncing user profile', failure);
            return AuthState.unknown();
          },
        );
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

          _authRepository.signOut();

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
            return await _syncUserProfile();
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
            if (_isProcessingRegistration) {
              _log.info(
                'Ignoring stream-based sign-in because registration is in progress',
              );
              break;
            }
            state = const AsyncValue.loading();
            state = AsyncValue.data(await _syncUserProfile());
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

  Future<ResultDart<SignInDomainResult, AuthFailure>> signIn(
    SignInParams params,
  ) async {
    _log.info('Attempting to sign in user: ${params.phoneNumber}');
    final result = await _authRepository.signInUser(params);
    await result.fold(
      (SignInDomainResult success) async {
        _log.info('Successfully signed in user: ${params.phoneNumber}');
      },
      (failure) {
        _log.error('Error signing in user: ${params.phoneNumber}', failure);
      },
    );
    return result;
  }

  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUp(
    SignUpParams params,
  ) async {
    final tempPassword = PasswordGenerator.generateSecureTempPassword();
    _log.info('Attempting to create account for user: ${params.phoneNumber}');
    await _secureStorage.write(
      key: 'temp_pass_${params.phoneNumber}',
      value: tempPassword,
    );
    final paramsWithPass = params.copyWith(password: tempPassword);
    final result = await _authRepository.signUpUser(paramsWithPass);
    result.fold(
      (success) {
        _log.info(
          'Successfully created account for user: ${params.phoneNumber}',
        );
      },
      (failure) {
        _log.error(
          'Error creating account for user: ${params.phoneNumber}',
          failure,
        );
      },
    );
    return result;
  }

  Future<ResultDart<SignUpDomainResult, AuthFailure>> confirmSignUp(
    ConfirmSignUpParams params,
  ) async {
    _log.info('Attempting to confirm sign up for user: ${params.username}');
    final result = await _authRepository.confirmSignUp(params);
    result.fold(
      (success) {
        _log.info(
          'Successfully confirmed sign up for user: ${params.username}',
        );
      },
      (failure) {
        _log.error(
          'Error confirming sign up for user: ${params.username}',
          failure,
        );
      },
    );
    return result;
  }

  Future<ResultDart<void, AuthFailure>> resendSignUpCode(
    String username,
  ) async {
    _log.info('Attempting to resend sign up code to user: $username');
    final result = await _authRepository.resendSignUpCode(username);
    result.fold(
      (success) {
        _log.info('Successfully resent sign up code to user: $username');
      },
      (failure) {
        _log.error('Error resending sign up code to user: $username', failure);
      },
    );
    return result;
  }

  Future<ResultDart<void, AuthFailure>> confirmSignUpAndSetPassword({
    required String phoneNumber,
    required String password,
  }) async {
    final storageKey = 'temp_pass_$phoneNumber';

    try {
      _isProcessingRegistration = true; // Lock engaged

      final tempPass = await _secureStorage.read(key: storageKey);
      if (tempPass == null) return Failure(AuthFailure.unknown());

      final result = await _authRepository
          .signInUser(
            SignInParams(phoneNumber: phoneNumber, password: tempPass),
          )
          .flatMap(
            (signInResult) => _authRepository.updatePassword(
              UpdatePasswordParams(
                oldPassword: tempPass,
                newPassword: password,
              ),
            ),
          );

      return await result.fold((success) async {
        await _secureStorage.delete(key: storageKey);
        final newState = await _syncUserProfile(isCompilingRegistration: true);
        state = AsyncValue.data(newState);
        return Success.unit();
      }, (failure) => Failure(failure));
    } finally {
      _isProcessingRegistration = false; // Always release the lock
    }
  }

  void completeOnboarding() {
    state.whenData((currentState) {
      if (currentState is SignedIn) {
        state = AsyncValue.data(
          currentState.copyWith(isRegistrationComplete: true),
        );
      }
    });
  }

  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>> resetPassword(
    String phoneNumber,
  ) async {
    _log.info('Attempting to reset password for user');
    final result = await _authRepository.resetPassword(phoneNumber);
    result.fold(
      (success) {
        _log.info('Successfully reset password for user');
      },
      (failure) {
        _log.error('Error resetting password for user', failure);
      },
    );
    return result;
  }

  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>>
  confirmResetPassword(ConfirmResetPasswordParams params) async {
    _log.info(
      'Attempting to confirm reset password for user: ${params.username}',
    );
    final result = await _authRepository.confirmResetPassword(params);
    result.fold(
      (success) {
        _log.info(
          'Successfully confirmed reset password for user: ${params.username}',
        );
      },
      (failure) {
        _log.error(
          'Error confirming reset password for user: ${params.username}',
          failure,
        );
      },
    );
    return result;
  }

  Future<ResultDart<UpdatePasswordDomainResult, AuthFailure>> updatePassword(
    UpdatePasswordParams params,
  ) async {
    _log.info('Attempting to update password for user');
    final result = await _authRepository.updatePassword(params);
    await result.fold(
      (UpdatePasswordDomainResult success) {
        _log.info('Successfully updated password for user');
      },
      (failure) {
        _log.error('Error updating password for user', failure);
      },
    );
    return result;
  }
}
