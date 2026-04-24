import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_user_attribute_result.freezed.dart';

@freezed
sealed class UpdateUserAttributeDomainResult with _$UpdateUserAttributeDomainResult {
  const factory UpdateUserAttributeDomainResult.success() = UpdateUserAttributeSuccess;

  const factory UpdateUserAttributeDomainResult.confirmationRequired({
    required String destination,
    required String deliveryMedium,
  }) = UpdateUserAttributeConfirmationRequired;
}
