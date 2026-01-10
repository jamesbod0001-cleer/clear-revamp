import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_password_result.freezed.dart';

@freezed
sealed class UpdatePasswordDomainResult with _$UpdatePasswordDomainResult {
  const factory UpdatePasswordDomainResult.success() = UpdatePasswordSuccess;
}
