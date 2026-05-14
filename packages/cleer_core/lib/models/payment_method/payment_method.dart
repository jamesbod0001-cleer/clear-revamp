import 'package:cleer_core/cleer_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method.freezed.dart';

@freezed
abstract class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id, // pmd_...
    required PaymentMethodType type,
    CardDetails? cardDetails, // Only present if type == card
    USSDDetails? ussdDetails, // Only present if type == ussd
    DateTime? createdAt,
  }) = _PaymentMethod;
}

@freezed
abstract class CardDetails with _$CardDetails {
  const CardDetails._();
  const factory CardDetails({
    required String first6,
    required String last4,
    required CardNetwork network,
    required int expiryMonth,
    required int expiryYear,
    String? cardHolderName,
  }) = _CardDetails;

  String get maskedNumber {
    if (network == CardNetwork.americanExpress) {
      // Amex Style: 3712 ****** 12345 -> 3712 ****** *1234
      return '${first6.substring(0, 4)} ****** *$last4';
    }
    // Standard 4-4-4-4
    return '${first6.substring(0, 4)} **** **** *${last4.substring(1)}';
  }
}

@freezed
abstract class USSDDetails with _$USSDDetails {
  const factory USSDDetails({required String accountBankCode}) = _USSDDetails;
}
