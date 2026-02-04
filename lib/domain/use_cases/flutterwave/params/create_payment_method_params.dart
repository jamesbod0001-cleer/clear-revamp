import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_payment_method_params.freezed.dart';

@freezed
class CreatePaymentMethodParams with _$CreatePaymentMethodParams {
  // For Card Payments
  const factory CreatePaymentMethodParams.card({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? cardHolderName,
  }) = _CardParams;

  // For OPay Payments (Usually just need the intent/type)
  const factory CreatePaymentMethodParams.opay() = _OPayParams;

  // Add others as needed, like .bankAccount()
}
