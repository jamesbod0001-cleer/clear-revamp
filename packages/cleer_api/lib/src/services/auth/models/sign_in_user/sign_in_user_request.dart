import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_user_request.freezed.dart';

@freezed
abstract class SignInUserRequest with _$SignInUserRequest {
  const factory SignInUserRequest({
    /// Username
    required String username,

    /// Plain Text Password
    required String password,
  }) = _SignInUserRequest;
}
