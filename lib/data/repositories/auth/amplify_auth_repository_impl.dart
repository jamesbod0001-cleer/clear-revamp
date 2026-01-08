import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_exceptions/amplify_auth_exception_handler.dart';
import 'package:cleer/data/mappers/amplify_auth_mappers.dart';
import 'package:cleer/data/repositories/auth/auth_repository.dart';
import 'package:cleer/data/services/auth/amplify_auth_service_client.dart';
import 'package:cleer/data/services/auth/models/sign_up_user/sign_up_user_request.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
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
