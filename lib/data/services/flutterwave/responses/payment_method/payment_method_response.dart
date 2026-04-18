import 'package:cleer/data/services/flutterwave/models/address/address_object.dart';
import 'package:cleer/data/services/flutterwave/models/cof/cof_object.dart';
import 'package:cleer/data/services/flutterwave/models/ussd/ussd_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method_response.g.dart';

@JsonSerializable()
class PaymentMethodResponse {
  final String type;

  CardResponseObject? card;
  USSDObject? ussd;

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
    this.ussd,

    this.customerId,
    this.meta,
    this.deviceFingerprint,
    this.clientIp,
    required this.createdDatetime,
  });

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodResponseToJson(this);
}

@JsonSerializable()
class CardResponseObject {
  @JsonKey(name: 'expiry_month')
  final int expiryMonth;
  @JsonKey(name: 'expiry_year')
  final int expiryYear;
  final String first6;
  final String last4;
  final String network;
  @JsonKey(name: 'bill_address')
  final AddressObject? billingAddress;
  @JsonKey(name: 'card_holder_name')
  final String? cardHolderName;

  final COFObject cof;

  CardResponseObject({
    required this.expiryMonth,
    required this.expiryYear,
    required this.first6,
    required this.last4,
    required this.network,
    this.billingAddress,
    this.cardHolderName,
    required this.cof,
  });

  factory CardResponseObject.fromJson(Map<String, dynamic> json) =>
      _$CardResponseObjectFromJson(json);
  Map<String, dynamic> toJson() => _$CardResponseObjectToJson(this);
}
