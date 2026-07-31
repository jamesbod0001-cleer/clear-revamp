import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/code_delivery_details/code_delivery_details.dart';
import 'package:cleer_core/models/confirm_user_attribute_result/confirm_user_attribute_result.dart';
import 'package:cleer_core/models/reset_password_result/reset_password_result.dart';
import 'package:cleer_core/models/sign_in_result/sign_in_result.dart';
import 'package:cleer_core/models/sign_up_result/sign_up_result.dart';
import 'package:cleer_core/models/update_password_result/update_password_result.dart';
import 'package:cleer_core/models/update_user_attribute_result/update_user_attribute_result.dart';
import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

part 'auth_use_case.g.dart';

@Riverpod(keepAlive: true)
class AuthUseCase extends _$AuthUseCase {
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final FlutterwaveRepository _flutterwaveRepository;
  late final SecureStorageService _secureStorageService;
  bool _isProcessingRegistration = false;

  final _log = AmplifyLogger("AuthUseCase");

  StreamSubscription<AppAuthStatus>? _authStatusSub;

  @override
  FutureOr<AuthState> build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _flutterwaveRepository = ref.watch(flutterwaveRepositoryProvider);
    _secureStorageService = ref.watch(secureStorageServiceProvider);

    _initialiseAuthStatus();
    _listenToAuthStateChanges();

    ref.onDispose(() {
      _authStatusSub?.cancel();
    });

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
            // On network failure during profile sync, we still want to throw
            // so the caller can fall back to the Passport cache.
            throw failure;
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
        
        // For network or unknown failures, throw so we can check the cache
        throw onFailure;
      },
    );
  }

  AuthState _finalizeSignIn(
    AuthIdentity identity,
    User user,
    bool isCompilingRegistration,
  ) {
    _log.info('Successfully synced user profile');
    
    // Save to Passport cache for offline access (Mobile only)
    if (!kIsWeb) {
      _secureStorageService.savePassport(identity);
    }

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

    final isSignedInResult = await _authRepository.isSignedIn();

    state = await AsyncValue.guard(() async {
      final isSignedIn = isSignedInResult.getOrDefault(false);

      if (isSignedIn) {
        _log.info('User is signed in');

        // 1. Try to sync with network (Fastest/Latest)
        try {
          return await _syncUserProfile().timeout(
            const Duration(seconds: 5),
          );
        } catch (e) {
          _log.warn('Network sync timed out or failed. Checking cache...', e);

          // 2. Fallback to Cached Passport (Offline Access)
          if (!kIsWeb) {
            final cachedIdentity =
                await _secureStorageService.getCachedPassport();
            if (cachedIdentity != null) {
              _log.info('Entering app using cached Passport');
              return AuthState.signedIn(identity: cachedIdentity);
            }
          }

          // 3. Last Resort: Try sync again without timeout if no cache
          // If this fails, it will throw and be caught by AsyncValue.guard
          return await _syncUserProfile();
        }
      } else {
        _log.info('User is not signed in');
        return AuthState.signedOut();
      }
    });
  }

  void _listenToAuthStateChanges() {
    _authStatusSub?.cancel();
    _authStatusSub = _authRepository.authStatus.listen(
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
    _log.info('Attempting to sign in user: ${params.identifier}');
    final result = await _authRepository.signInUser(params);
    await result.fold(
      (SignInDomainResult success) async {
        _log.info('Successfully signed in user: ${params.identifier}');
      },
      (failure) {
        _log.error('Error signing in user: ${params.identifier}', failure);
      },
    );
    return result;
  }

  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUp(
    SignUpParams params,
  ) async {
    final tempPassword = PasswordGenerator.generateSecureTempPassword();
    final generatedUsername = const Uuid().v4();

    _log.info('Attempting to create account for user: ${params.phoneNumber}');
    await _secureStorageService.saveTempPassword(
      params.phoneNumber,
      tempPassword,
    );
    await _secureStorageService.saveHiddenUsername(
      params.phoneNumber,
      generatedUsername,
    );
    final paramsWithAuth = params.copyWith(
      username: generatedUsername,
      password: tempPassword,
    );
    final result = await _authRepository.signUpUser(paramsWithAuth);
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
    final hiddenUsername = await _secureStorageService.getHiddenUsername(
      params.identifier,
    );

    if (hiddenUsername == null) return Failure(AuthFailure.unknown());

    _log.info('Attempting to confirm sign up for UUID: $hiddenUsername');

    // Swap the identifier for the hidden username before sending it to the repo
    final realParams = params.copyWith(identifier: hiddenUsername);

    final result = await _authRepository.confirmSignUp(realParams);

    result.fold(
      (success) {
        _secureStorageService.deleteHiddenUsername(params.identifier);
        _log.info(
          'Successfully confirmed sign up for user: ${params.identifier}',
        );
      },
      (failure) {
        _log.error(
          'Error confirming sign up for user: ${params.identifier}',
          failure,
        );
      },
    );
    return result;
  }

  Future<ResultDart<void, AuthFailure>> resendSignUpCode(
    String identifier,
  ) async {
    final hiddenUsername = await _secureStorageService.getHiddenUsername(
      identifier,
    );
    if (hiddenUsername == null) return Failure(AuthFailure.unknown());

    _log.info('Attempting to resend sign up code to UUID: $hiddenUsername');
    final result = await _authRepository.resendSignUpCode(hiddenUsername);
    result.fold(
      (success) {
        _log.info('Successfully resent sign up code to user: $identifier');
      },
      (failure) {
        _log.error(
          'Error resending sign up code to user: $identifier',
          failure,
        );
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
          .signInUser(SignInParams(identifier: phoneNumber, password: tempPass))
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
          await _secureStorageService.deleteHiddenUsername(phoneNumber);

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
    state = const AsyncValue.loading();

    // Clear device token from backend first
    final authState = state.value;
    final userId = authState?.currentUserAuthIdentity?.userId;

    if (userId != null) {
      _log.info('Clearing device token from backend during sign-out');
      try {
        // Best-effort cleanup with a timeout to prevent hanging the sign-out flow
        final result = await _userRepository
            .updateDeviceToken(userId, null)
            .timeout(const Duration(seconds: 3));

        result.fold(
          (_) => _log.info('Successfully cleared device token'),
          (failure) => _log.error('Failed to clear device token: $failure'),
        );
      } catch (e) {
        _log.error(
          'Error or timeout clearing device token during sign-out: $e',
        );
      }
    }

    final result = await _authRepository.signOut();
    result.fold(
      (success) {
        _log.info('Successfully signed out user');
        if (!kIsWeb) {
          _secureStorageService.clearPassport();
        }
        state = AsyncValue.data(AuthState.signedOut());
      },
      (failure) {
        _log.error('Error signing out user', failure);
      },
    );
    return result;
  }

  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>> resetPassword(
    String identifier,
  ) async {
    _log.info('Attempting to reset password for user');
    final result = await _authRepository.resetPassword(identifier);
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
      'Attempting to confirm reset password for user: ${params.identifier}',
    );
    final result = await _authRepository.confirmResetPassword(params);
    result.fold(
      (success) {
        _log.info(
          'Successfully confirmed reset password for user: ${params.identifier}',
        );
      },
      (failure) {
        _log.error(
          'Error confirming reset password for user: ${params.identifier}',
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

  Future<ResultDart<UpdateUserAttributeDomainResult, AuthFailure>> updateEmail(
    String newEmail,
  ) async {
    _log.info('User is requesting an email update to: $newEmail');

    final result = await _authRepository.updateEmail(newEmail);

    return await result.fold(
      (success) async {
        // If Cognito says it's done (no verification needed), sync the DB now!
        if (success is UpdateUserAttributeSuccess) {
          // Or whatever your success check is
          _log.info('Email updated immediately. Syncing profile...');
          await _syncUserProfile();
        }
        _log.info('Email update result: $success');
        return Success(success);
      },
      (failure) {
        _log.error('Failed to initiate email update', failure);
        return Failure(failure);
      },
    );
  }
}
