import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_exceptions/amplify_auth_exception_handler.dart';
import 'package:cleer/data/mappers/amplify_auth_mappers.dart';
import 'package:cleer/data/repositories/auth/auth_repository.dart';
import 'package:cleer/data/services/auth/amplify_auth_service_client.dart';
import 'package:cleer/data/services/auth/models/confirm_reset_password/confirm_reset_password_request.dart';
import 'package:cleer/data/services/auth/models/confirm_sign_up/confirm_sign_up_request.dart';
import 'package:cleer/data/services/auth/models/sign_in_user/sign_in_user_request.dart';
import 'package:cleer/data/services/auth/models/sign_up_user/sign_up_user_request.dart';
import 'package:cleer/data/services/auth/models/update_password/update_password_request.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/auth_identity/auth_identity.dart';
import 'package:cleer/domain/models/code_delivery_details/code_delivery_details.dart';
import 'package:cleer/domain/models/enums/app_auth_status.dart';
import 'package:cleer/domain/models/reset_password_result/reset_password_result.dart';
import 'package:cleer/domain/models/sign_in_result/sign_in_result.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/models/update_password_result/update_password_result.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_reset_password_params.dart';
import 'package:cleer/domain/use_cases/auth/params/confirm_sign_up_params.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_in_params.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_up_params.dart';
import 'package:cleer/domain/use_cases/auth/params/update_password_params.dart';
import 'package:result_dart/result_dart.dart';

class AmplifyAuthRepositoryImpl extends AuthRepository {
  final AmplifyAuthServiceClient _amplifyAuthServiceClient;

  AmplifyAuthRepositoryImpl({
    required AmplifyAuthServiceClient amplifyAuthServiceClient,
  }) : _amplifyAuthServiceClient = amplifyAuthServiceClient;

  final _log = AmplifyLogger('AmplifyAuthRepositoryImpl');

  @override
  Stream<AppAuthStatus> get authStatus {
    return _amplifyAuthServiceClient.authStatus;
  }

  @override
  Future<ResultDart<bool, AuthFailure>> isSignedIn() async {
    try {
      _log.info('Checking if user is signed in');
      final result = await _amplifyAuthServiceClient.isSignedIn();
      _log.info('User signed in status: $result');
      return Success(result);
    } on AuthException catch (e) {
      _log.error('Error checking if user is signed in', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<AuthIdentity, AuthFailure>> getAuthIdentity() async {
    try {
      _log.info('Getting Current User Auth Identity');

      final attributes = await _amplifyAuthServiceClient
          .fetchCurrentUserAttributes();
      final result = attributes.toDomain();
      _log.info('Successfully got current user auth identity: $result');
      return Success(result);
    } on AuthException catch (e) {
      _log.error('Error getting auth identity', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<SignInDomainResult, AuthFailure>> signInUser(
    SignInParams params,
  ) async {
    try {
      _log.info('Starting Sign In for user: ${params.username}');
      final request = SignInUserRequest(
        username: params.username,
        password: params.password,
      );
      final amplifyResult = await _amplifyAuthServiceClient.signInUser(request);

      if (amplifyResult.nextStep.signInStep == AuthSignInStep.confirmSignUp) {
        _log.info('User is not confirmed. Resending confirmation code.');
        final resendResult = await resendSignUpCode(params.username);
        return resendResult.fold(
          (codeDetails) => Success(
            SignInDomainResult.confirmationRequired(
              destination: codeDetails.destination!,
              deliveryMedium: codeDetails.deliveryMedium!,
            ),
          ),
          (failure) => Failure(failure),
        );
      }

      _log.info('Sign In successful for user: ${params.username}');
      return Success(amplifyResult.toDomain());
    } on AuthException catch (e) {
      _log.error('Error signing in user: ${params.username}', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUpUser(
    SignUpParams params,
  ) async {
    try {
      _log.info('Starting Sign Up for user: ${params.phoneNumber}');
      final request = SignUpUserRequest(
        firstName: params.firstName,
        lastName: params.lastName,
        phoneNumber: params.phoneNumber,
        email: params.email,
        password: params.password,
      );
      final amplifyResult = await _amplifyAuthServiceClient.signUpUser(request);
      _log.info('Sign Up successful for user: ${params.phoneNumber}');
      return Success(amplifyResult.toDomain());
    } on AuthException catch (e) {
      _log.error('Error signing up user: ${params.phoneNumber}', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<SignUpDomainResult, AuthFailure>> confirmSignUp(
    ConfirmSignUpParams params,
  ) async {
    try {
      _log.info('Starting Sign Up confirmation for user: ${params.username}');
      final request = ConfirmSignUpRequest(
        username: params.username,
        confirmationCode: params.confirmationCode,
      );
      final amplifyResult = await _amplifyAuthServiceClient.confirmSignUp(
        request,
      );
      _log.info('Sign Up confirmation successful for user: ${params.username}');
      return Success(amplifyResult.toDomain());
    } on AuthException catch (e) {
      _log.error('Error confirming sign up for user: ${params.username}', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<CodeDeliveryDetails, AuthFailure>> resendSignUpCode(
    String username,
  ) async {
    try {
      _log.info('Resending Sign Up code for user: $username');
      final result = await _amplifyAuthServiceClient.resendSignUpCode(username);
      _log.info('Sign Up code resent successfully for user: $username');
      return Success(result.codeDeliveryDetails.toDomain());
    } on AuthException catch (e) {
      _log.error('Error resending sign up code for user: $username', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>> resetPassword(
    String username,
  ) async {
    try {
      _log.info('Resetting password for user: $username');
      final amplifyResult = await _amplifyAuthServiceClient.resetPassword(
        username,
      );
      _log.info('Password reset successful for user: $username');
      return Success(amplifyResult.toDomain());
    } on AuthException catch (e) {
      _log.error('Error resetting password for user: $username', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>>
  confirmResetPassword(ConfirmResetPasswordParams params) async {
    try {
      _log.info('Confirming password reset for user ${params.username}');
      final request = ConfirmResetPasswordRequest(
        username: params.username,
        newPassword: params.newPassword,
        confirmationCode: params.confirmationCode,
      );
      final amplifyResult = await _amplifyAuthServiceClient
          .confirmResetPassword(request);
      _log.info(
        'Password reset confirmed successfully for user ${params.username}',
      );
      return Success(amplifyResult.toDomain());
    } on AuthException catch (e) {
      _log.error(
        'Error confirming password reset for user ${params.username}',
        e,
      );
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<UpdatePasswordDomainResult, AuthFailure>> updatePassword(
    UpdatePasswordParams params,
  ) async {
    try {
      _log.info('Updating password for user');
      final request = UpdatePasswordRequest(
        oldPassword: params.oldPassword,
        newPassword: params.newPassword,
      );
      final amplifyResult = await _amplifyAuthServiceClient.updatePassword(
        request,
      );
      _log.info('Password updated successfully');
      return Success(amplifyResult.toDomain());
    } on AuthException catch (e) {
      _log.error('Error updating password', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }

  @override
  Future<ResultDart<void, AuthFailure>> signOut() async {
    try {
      _log.info('Signing out user');
      final result = await _amplifyAuthServiceClient.signOutCurrentUser();
      if (result is CognitoCompleteSignOut) {
        _log.info('Successfully signed out user');
        return Success.unit();
      } else if (result is CognitoFailedSignOut) {
        _log.error('Error signing out user', result.exception);
        return Failure(AuthFailure.unknown(message: result.exception.message));
      } else {
        _log.error('Unknown error signing out user');
        return Failure(AuthFailure.unknown());
      }
    } on AuthException catch (e) {
      _log.error('Error signing out user', e);
      return Failure(AmplifyAuthExceptionHandler.handleException(e));
    }
  }
}
