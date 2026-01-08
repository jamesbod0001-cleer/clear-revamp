import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/services/amplify_providers.dart';
import 'package:cleer/data/services/auth/models/sign_up_user/sign_up_user_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amplify_auth_service_client.g.dart';

@riverpod
AmplifyAuthServiceClient amplifyAuthServiceClient(Ref ref) =>
    AmplifyAuthServiceClient(
      amplifyAuth: ref.watch(amplifyAuthProvider),
      amplifyHub: ref.watch(amplifyHubProvider),
    );

class AmplifyAuthServiceClient {
  final AuthCategory _amplifyAuth;
  final AmplifyHub _amplifyHub;

  AmplifyAuthServiceClient({
    required AuthCategory amplifyAuth,
    required AmplifyHub amplifyHub,
  }) : _amplifyAuth = amplifyAuth,
       _amplifyHub = amplifyHub;

  /// Signs a user up with a phone number, and password.
  Future<SignUpResult> signUpUser(SignUpUserRequest request) async {
    final userAttributes = {
      AuthUserAttributeKey.phoneNumber: request.phoneNumber,
      if (request.email != null) AuthUserAttributeKey.email: request.email!,
      AuthUserAttributeKey.givenName: request.firstName,
      AuthUserAttributeKey.familyName: request.lastName,
    };
    final result = await _amplifyAuth.signUp(
      username: request.phoneNumber,
      password: request.password,
      options: SignUpOptions(userAttributes: userAttributes),
    );
    return result;
  }
}
