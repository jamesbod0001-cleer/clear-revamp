import 'package:cleer/domain/models/enums/card_network.dart';
import 'package:cleer/domain/models/enums/payment_method_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method.freezed.dart';

@freezed
abstract class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id, // pmd_...
    required PaymentMethodType type,
    CardDetails? cardDetails, // Only present if type == card
    DateTime? createdAt,
  }) = _PaymentMethod;
}

@freezed
abstract class CardDetails with _$CardDetails {
  const factory CardDetails({
    required String last4,
    required CardNetwork network,
    required String expiryMonth,
    required String expiryYear,
    String? cardHolderName,
  }) = _CardDetails;
}