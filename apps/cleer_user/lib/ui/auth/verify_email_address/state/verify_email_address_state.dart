import 'package:cleer_core/models/code_delivery_details/code_delivery_details.dart';
import 'package:cleer_core/models/confirm_user_attribute_result/confirm_user_attribute_result.dart';
import 'package:cleer_core/models/update_user_attribute_result/update_user_attribute_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_email_address_state.freezed.dart';

@freezed
abstract class VerifyEmailAddressState with _$VerifyEmailAddressState {
  const factory VerifyEmailAddressState({
    required CodeDeliveryDetails codeDeliveryDetails,
    ConfirmUserAttributeDomainResult? confirmUserAttributeDomainResult,
    UpdateUserAttributeDomainResult? updateUserAttributeDomainResult,
  }) = _VerifyEmailAddressState;
}
