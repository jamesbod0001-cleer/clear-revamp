import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_params.freezed.dart';

@freezed
abstract class SignInParams with _$SignInParams {
  const factory SignInParams({
    required String phoneNumber,
    required String password,
  }) = _SignInParams;
}
