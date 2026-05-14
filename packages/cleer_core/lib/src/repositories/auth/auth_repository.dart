import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/code_delivery_details/code_delivery_details.dart';
import 'package:cleer_core/models/confirm_user_attribute_result/confirm_user_attribute_result.dart';
import 'package:cleer_core/models/reset_password_result/reset_password_result.dart';
import 'package:cleer_core/models/sign_in_result/sign_in_result.dart';
import 'package:cleer_core/models/sign_up_result/sign_up_result.dart';
import 'package:cleer_core/models/update_password_result/update_password_result.dart';
import 'package:cleer_core/models/update_user_attribute_result/update_user_attribute_result.dart';
import 'package:result_dart/result_dart.dart';

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

  Future<ResultDart<CodeDeliveryDetails, AuthFailure>>
  sendEmailVerificationCode();
  Future<ResultDart<ConfirmUserAttributeDomainResult, AuthFailure>>
  confirmEmailVerificationCode(String confirmationCode);
  Future<ResultDart<UpdateUserAttributeDomainResult, AuthFailure>> updateEmail(
    String newEmail,
  );
}
