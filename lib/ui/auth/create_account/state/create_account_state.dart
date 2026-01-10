import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';

part 'create_account_state.freezed.dart';

@freezed
abstract class CreateAccountState with _$CreateAccountState {
  const factory CreateAccountState({
    required CreateAccountFormData createAccountFormData,
    SignUpDomainResult? signUpDomainResult,
  }) = _CreateAccountState;
}

@freezed
abstract class CreateAccountFormData with _$CreateAccountFormData {
  const factory CreateAccountFormData({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String phoneNumber,
    @Default('') String email,
  }) = _CreateAccountFormData;

  factory CreateAccountFormData.empty() => const CreateAccountFormData();
}
