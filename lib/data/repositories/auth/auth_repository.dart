import 'package:cleer/data/repositories/auth/amplify_auth_repository_impl.dart';
import 'package:cleer/data/services/auth/amplify_auth_service_client.dart';
import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/use_cases/auth/params/sign_up_params.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AmplifyAuthRepositoryImpl(
  amplifyAuthServiceClient: ref.watch(amplifyAuthServiceClientProvider),
);

abstract class AuthRepository {
  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUpUser(
    SignUpParams params,
  );
}
