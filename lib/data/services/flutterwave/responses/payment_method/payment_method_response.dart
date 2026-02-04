import 'package:cleer/data/services/flutterwave/models/address/address_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method_response.g.dart';

@JsonSerializable()
class PaymentMethodResponse {
  final String type;

  CardResponseObject? card;

  final String id;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'device_fingerprint')
  final String? deviceFingerprint;
  @JsonKey(name: 'client_ip')
  final String? clientIp;
  @JsonKey(name: 'created_datetime')
  final DateTime createdDatetime;

  PaymentMethodResponse({
    required this.type,
    required this.id,

    this.card,

    this.customerId,
    this.meta,
    this.deviceFingerprint,
    this.clientIp,
    required this.createdDatetime,
  });

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodResponseFromJson(json);
}

@JsonSerializable()
class CardResponseObject {
  @JsonKey(name: 'expiry_month')
  final String expiryMonth;
  @JsonKey(name: 'expiry_year')
  final String expiryYear;
  final String first6;
  final String last4;
  final String network;
  @JsonKey(name: 'bill_address')
  final AddressObject? billingAddress;
  @JsonKey(name: 'card_holder_name')
  final String? cardHolderName;

  CardResponseObject({
    required this.expiryMonth,
    required this.expiryYear,
    required this.first6,
    required this.last4,
    required this.network,
    this.billingAddress,
    this.cardHolderName,
  });

  factory CardResponseObject.fromJson(Map<String, dynamic> json) =>
      _$CardResponseObjectFromJson(json);
  Map<String, dynamic> toJson() => _$CardResponseObjectToJson(this);
}
