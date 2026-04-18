import 'package:cleer/data/services/flutterwave/models/cof/cof_object.dart';
import 'package:cleer/data/services/flutterwave/models/ussd/ussd_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_payment_method_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreatePaymentMethodRequest {
  final String type;
  final CardRequestObject? card;
  final USSDObject? ussd;

  @JsonKey(name: 'customer_id')
  final String? customerId;
  final Map<String, dynamic>? meta;

  CreatePaymentMethodRequest({
    required this.type,
    this.card,
    this.ussd,
    this.customerId,
    this.meta,
  });

  Map<String, dynamic> toJson() => _$CreatePaymentMethodRequestToJson(this);

  factory CreatePaymentMethodRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentMethodRequestFromJson(json);
}

@JsonSerializable(explicitToJson: true)
class CardRequestObject {
  @JsonKey(name: 'encrypted_card_number')
  final String encryptedCardNumber;
  @JsonKey(name: 'encrypted_expiry_month')
  final String encryptedExpiryMonth;
  @JsonKey(name: 'encrypted_expiry_year')
  final String encryptedExpiryYear;
  @JsonKey(name: 'encrypted_cvv')
  final String encryptedCvv;
  final String nonce;

  final COFObject cof;

  CardRequestObject({
    required this.encryptedCardNumber,
    required this.encryptedExpiryMonth,
    required this.encryptedExpiryYear,
    required this.encryptedCvv,
    required this.nonce,
    required this.cof,
  });

  factory CardRequestObject.fromJson(Map<String, dynamic> json) =>
      _$CardRequestObjectFromJson(json);
  Map<String, dynamic> toJson() => _$CardRequestObjectToJson(this);
}
