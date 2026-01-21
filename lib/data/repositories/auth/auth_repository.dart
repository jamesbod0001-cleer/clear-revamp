import 'package:cleer/data/repositories/auth/amplify_auth_repository_impl.dart';
import 'package:cleer/data/services/auth/amplify_auth_service_client.dart';
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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AmplifyAuthRepositoryImpl(
  amplifyAuthServiceClient: ref.watch(amplifyAuthServiceClientProvider),
);

abstract class AuthRepository {
  Stream<AppAuthStatus> get authStatus;
  Future<ResultDart<bool, AuthFailure>> isSignedIn();
  Future<ResultDart<AuthIdentity, AuthFailure>> getAuthIdentity();
  Future<ResultDart<SignInDomainResult, AuthFailure>> signInUser(
    SignInParams params,
  );
  Future<ResultDart<SignUpDomainResult, AuthFailure>> signUpUser(
    SignUpParams params,
  );
  Future<ResultDart<SignUpDomainResult, AuthFailure>> confirmSignUp(
    ConfirmSignUpParams params,
  );
  Future<ResultDart<CodeDeliveryDetails, AuthFailure>> resendSignUpCode(
    String username,
  );
  Future<ResultDart<UpdatePasswordDomainResult, AuthFailure>> updatePassword(
    UpdatePasswordParams params,
  );
  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>> resetPassword(
    String username,
  );
  Future<ResultDart<ResetPasswordDomainResult, AuthFailure>>
  confirmResetPassword(ConfirmResetPasswordParams params);
  Future<ResultDart<void, AuthFailure>> signOut();
}
