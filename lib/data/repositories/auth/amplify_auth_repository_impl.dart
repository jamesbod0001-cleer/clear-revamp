import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_exceptions/amplify_auth_exception_handler.dart';
import 'package:cleer/data/mappers/amplify_auth_mappers.dart';
import 'package:cleer/data/repositories/auth/auth_repository.dart';
import 'package:cleer/data/services/auth/amplify_auth_service_client.dart';
import 'package:cleer/data/services/auth/models/sign_up_user/sign_up_user_request.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/auth_identity/auth_identity.dart';
import 'package:cleer/domain/models/enums/app_auth_status.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_up_params.dart';
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
}
