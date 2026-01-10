import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_sign_up_params.freezed.dart';

@freezed
abstract class ConfirmSignUpParams with _$ConfirmSignUpParams {
  const factory ConfirmSignUpParams({
    required String username,
    required String confirmationCode,
  }) = _ConfirmSignUpParams;
}
