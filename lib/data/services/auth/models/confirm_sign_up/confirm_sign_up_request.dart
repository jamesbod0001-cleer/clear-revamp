import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_sign_up_request.freezed.dart';

@freezed
abstract class ConfirmSignUpRequest with _$ConfirmSignUpRequest {
  const factory ConfirmSignUpRequest({
    /// Username
    required String username,

    /// Confirmation code
    required String confirmationCode,
  }) = _ConfirmSignUpRequest;
}
