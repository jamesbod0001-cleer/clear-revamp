import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_user_request.freezed.dart';

@freezed
abstract class SignUpUserRequest with _$SignUpUserRequest {
  const factory SignUpUserRequest({
    /// First Name
    required String firstName,

    /// Last Name
    required String lastName,

    /// Phone number
    required String phoneNumber,

    /// Email Address
    String? email,

    /// Plain Text Password
    required String password,
  }) = _SignUpUserRequest;
}
