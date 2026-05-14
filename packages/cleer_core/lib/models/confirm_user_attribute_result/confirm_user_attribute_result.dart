import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_user_attribute_result.freezed.dart';

@freezed
sealed class ConfirmUserAttributeDomainResult
    with _$ConfirmUserAttributeDomainResult {
  const factory ConfirmUserAttributeDomainResult.success() =
      ConfirmUserAttributeSuccess;
}
