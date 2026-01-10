import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_password_params.freezed.dart';

@freezed
abstract class UpdatePasswordParams with _$UpdatePasswordParams {
  const factory UpdatePasswordParams({
    required String oldPassword,
    required String newPassword,
  }) = _UpdatePasswordParams;
}
