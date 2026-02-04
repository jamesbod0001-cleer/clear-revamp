import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_payment_method_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreatePaymentMethodRequest {
  final String type;
  final CardRequestObject? card;

  CreatePaymentMethodRequest({required this.type, this.card});

  Map<String, dynamic> toJson() => _$CreatePaymentMethodRequestToJson(this);
}

@JsonSerializable()
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

  CardRequestObject({
    required this.encryptedCardNumber,
    required this.encryptedExpiryMonth,
    required this.encryptedExpiryYear,
    required this.encryptedCvv,
    required this.nonce,
  });

  factory CardRequestObject.fromJson(Map<String, dynamic> json) =>
      _$CardRequestObjectFromJson(json);
  Map<String, dynamic> toJson() => _$CardRequestObjectToJson(this);
}
