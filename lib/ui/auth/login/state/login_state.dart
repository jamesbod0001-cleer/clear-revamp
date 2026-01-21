import 'package:cleer/domain/models/sign_in_result/sign_in_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    required LoginFormData loginFormData,
    @Default(false) bool isEmailMode,
    SignInDomainResult? signInDomainResult,
  }) = _LoginState;
}

@freezed
abstract class LoginFormData with _$LoginFormData {
  const factory LoginFormData({
    @Default('') String phoneNumber,
    @Default('') String email,
    @Default('') String password,
  }) = _LoginFormData;

  factory LoginFormData.empty() => const LoginFormData();
}
