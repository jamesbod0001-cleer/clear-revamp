import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/user/user_repository.dart';
import 'package:cleer/data/repositories/auth/auth_repository.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/data/services/local/secure_storage_service.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/auth_identity/auth_identity.dart';
import 'package:cleer/domain/models/code_delivery_details/code_delivery_details.dart';
import 'package:cleer/domain/models/confirm_user_attribute_result/confirm_user_attribute_result.dart';
import 'package:cleer/domain/models/enums/app_auth_status.dart';
import 'package:cleer/domain/models/reset_password_result/reset_password_result.dart';
import 'package:cleer/domain/models/sign_in_result/sign_in_result.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/models/update_password_result/update_password_result.dart';
import 'package:cleer/domain/models/update_user_attribute_result/update_user_attribute_result.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_reset_password_params.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_sign_up_params.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_in_params.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_up_params.dart';
import 'package:cleer/domain/use_cases/auth/params/update_password_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_customer_params.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/utils/constants.dart';
import 'package:cleer/utils/password_generator.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'auth_use_case.g.dart';

@Riverpod(keepAlive: true)
class AuthUseCase extends _$AuthUseCase {
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final FlutterwaveRepository _flutterwaveRepository;
  late final SecureStorageService _secureStorageService;
  bool _isProcessingRegistration = false;

  final _log = AmplifyLogger("AuthUseCase");

  @override
  FutureOr<AuthState> build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _flutterwaveRepository = ref.watch(flutterwaveRepositoryProvider);
    _secureStorageService = ref.watch(secureStorageServiceProvider);
    _initialiseAuthStatus();
    _listenToAuthStateChanges();
    return AuthState.unknown();
  }

  Future<AuthState> _syncUserProfile({
    bool isCompilingRegistration = false,
    String flutterwaveCustomerId = kEmpty,
  }) async {
    final identityResult = await _authRepository.getAuthIdentity();

    return await identityResult.fold(
      (identity) async {
        _log.info('Current user auth identity: $identity');

        // Get (or create) the user from the DB
        final syncResult = await _userRepository.getOrCreateUserProfile(
          User(
            id: identity.userId,
            identityId: identity.identityId,
            firstName: identity.firstName,
            lastName: identity.lastName,
            phoneNumber: identity.phoneNumber,
            email: identity.email,
            isEmailVerified: identity.isEmailVerified, // New field
            flutterwaveCustomerId: flutterwaveCustomerId,
          ),
        );

        return await syncResult.fold(
          (userFromDb) async {
            // Check if the DB record is out of sync with Cognito
            if (userFromDb.isEmailVerified != identity.isEmailVerified ||
                userFromDb.email != identity.email) {
              _log.info(
                'DB out of sync with Cognito. Patching user profile...',
              );

              final updatedUser = userFromDb.copyWith(
                isEmailVerified: identity.isEmailVerified,
                email: identity.email,
              );

              // We fire this and wait for it so the UI state is perfect
              final updateResult = await _userRepository.updateUserProfile(
                updatedUser,
              );

              return updateResult.fold(
                (patchedUser) => _finalizeSignIn(
                  identity,
                  patchedUser,
                  isCompilingRegistration,
                ),
                (failure) => _finalizeSignIn(
                  identity,
                  userFromDb,
                  isCompilingRegistration,
                ), // Fallback to stale if update fails
              );
            }

            return _finalizeSignIn(
              identity,
              userFromDb,
              isCompilingRegistration,
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

  AuthState _finalizeSignIn(
    AuthIdentity identity,
    User user,
    bool isCompilingRegistration,
  ) {
    _log.info('Successfully synced user profile');
    Sentry.configureScope(
      (scope) => scope.setUser(
        SentryUser(
          id: identity.userId,
          email: identity.email,
          username: "${identity.firstName} ${identity.lastName}",
          data: {'phone': identity.phoneNumber},
        ),
      ),
    );
    return AuthState.signedIn(
      identity: identity,
      isRegistrationComplete: !isCompilingRegistration,
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
    _log.info('Attempting to sign in user: ${params.username}');
    final result = await _authRepository.signInUser(params);
    await result.fold(
      (SignInDomainResult success) async {
        _log.info('Successfully signed in user: ${params.username}');
      },
      (failure) {
        _log.error('Error signing in user: ${params.username}', failure);
      },
    );
    return result;
  }

  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUp(
    SignUpParams params,
  ) async {
    final tempPassword = PasswordGenerator.generateSecureTempPassword();
    _log.info('Attempting to create account for user: ${params.phoneNumber}');
    await _secureStorageService.saveTempPassword(
      params.phoneNumber,
      tempPassword,
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
    try {
      _isProcessingRegistration = true;

      final tempPass = await _secureStorageService.getTempPassword(phoneNumber);
      if (tempPass == null) return Failure(AuthFailure.unknown());

      _log.info('Attempting to confirm sign up for user: $phoneNumber');
      final authResult = await _authRepository
          .signInUser(SignInParams(username: phoneNumber, password: tempPass))
          .flatMap(
            (_) => _authRepository.updatePassword(
              UpdatePasswordParams(
                oldPassword: tempPass,
                newPassword: password,
              ),
            ),
          );

      _log.info('Auth result: $authResult');
      return await authResult.fold(
        (success) async {
          await _secureStorageService.deleteTempPassword(phoneNumber);

          final identityResult = await _authRepository.getAuthIdentity();

          return await identityResult.fold(
            (identity) async {
              _log.info(
                'Creating mandatory Flutterwave customer for: ${identity.userId}',
              );
              final customerResult = await _flutterwaveRepository
                  .createCustomer(
                    params: CreateCustomerParams(
                      firstName: identity.firstName,
                      lastName: identity.lastName,
                      phoneNumber: phoneNumber,
                    ),
                    userId: identity.userId,
                  );

              return await customerResult.fold(
                (customer) async {
                  _log.info(
                    'Successfully created mandatory Flutterwave customer for: ${identity.userId}',
                  );
                  final newState = await _syncUserProfile(
                    isCompilingRegistration: true,
                    flutterwaveCustomerId: customer.id, // Passing the ID
                  );
                  _log.info('New state: $newState');
                  state = AsyncValue.data(newState);
                  return Success.unit();
                },
                // Map PaymentFailure to AuthFailure if necessary
                (paymentFailure) {
                  _log.error(
                    'CRITICAL: Flutterwave customer creation failed. Blocking registration.',
                    paymentFailure,
                  );
                  return Failure(AuthFailure.unknown());
                },
              );
            },
            (failure) {
              _log.error('Error getting auth identity', failure);
              return Failure(AuthFailure.unknown());
            },
          );
        },
        (failure) {
          _log.error(
            'Error confirming sign up for user: $phoneNumber',
            failure,
          );
          return Failure(failure);
        },
      );
    } finally {
      _isProcessingRegistration = false;
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

  Future<ResultDart<void, AuthFailure>> signOut() async {
    _log.info('Attempting to sign out user');
    final result = await _authRepository.signOut();
    result.fold(
      (success) {
        _log.info('Successfully signed out user');
        state = AsyncValue.data(AuthState.signedOut());
      },
      (failure) {
        _log.error('Error signing out user', failure);
      },
    );
    return result;
  }

  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>> resetPassword(
    String username,
  ) async {
    _log.info('Attempting to reset password for user');
    final result = await _authRepository.resetPassword(username);
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

  Future<ResultDart<CodeDeliveryDetails, AuthFailure>>
  sendEmailVerificationCode() async {
    _log.info('Attempting to send email verification code');

    final result = await _authRepository.sendEmailVerificationCode();

    result.fold(
      (success) {
        _log.info(
          'Successfully sent email verification code to: ${success.destination}',
        );
      },
      (failure) {
        _log.error('Error sending email verification code', failure);
      },
    );

    return result;
  }

  Future<ResultDart<ConfirmUserAttributeDomainResult, AuthFailure>>
  confirmEmailVerificationCode(String confirmationCode) async {
    _log.info('Attempting to confirm email verification code');

    final result = await _authRepository.confirmEmailVerificationCode(
      confirmationCode,
    );

    return await result.fold(
      (success) async {
        _log.info(
          'Successfully confirmed email verification code. Triggering sync...',
        );

        await _syncUserProfile();
        return Success(success);
      },
      (failure) {
        _log.error('Error confirming email verification code', failure);
        return Failure(failure);
      },
    );
  }

  Future<ResultDart<UpdateUserAttributeDomainResult, AuthFailure>> changeEmail(
    String newEmail,
  ) async {
    _log.info('User is requesting an email change to: $newEmail');

    final result = await _authRepository.updateEmail(newEmail);

    return await result.fold(
      (success) async {
        // If Cognito says it's done (no verification needed), sync the DB now!
        if (success is UpdateUserAttributeSuccess) {
          // Or whatever your success check is
          _log.info('Email updated immediately. Syncing profile...');
          await _syncUserProfile();
        }
        _log.info('Email change result: $success');
        return Success(success);
      },
      (failure) {
        _log.error('Failed to initiate email change', failure);
        return Failure(failure);
      },
    );
  }
}
