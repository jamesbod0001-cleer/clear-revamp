import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_payment_method_params.freezed.dart';

@freezed
abstract class CreatePaymentMethodParams with _$CreatePaymentMethodParams {
  // For Card Payments
  const factory CreatePaymentMethodParams.card({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? cardHolderName,

    String? customerId,
    Map<String, dynamic>? meta,
  }) = _CardParams;

  // For OPay Payments (Usually just need the intent/type)
  const factory CreatePaymentMethodParams.opay({
    String? customerId,
    Map<String, dynamic>? meta,
  }) = _OPayParams;

  // For USSD Payments
  const factory CreatePaymentMethodParams.ussd({
    required String accountBankCode,
    String? customerId,
    Map<String, dynamic>? meta,
  }) = _USSDParams;

  // Add others as needed, like .bankAccount()
}
