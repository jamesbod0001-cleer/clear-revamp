import 'package:cleer/data/services/flutterwave/models/authorization/authorization_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_charge_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateChargeRequest {
  final double amount;
  final String currency;
  final String reference;
  @JsonKey(name: 'customer_id')
  final String customerId;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'payment_method_id')
  final String paymentMethodId;
  @JsonKey(name: 'redirect_url')
  final String? redirectUrl;
  final AuthorizationObject? authorization;
  final bool recurring;
  final String? orderId;
  @JsonKey(name: 'merchant_vat_amount')
  final String? merchantVatAmount;

  CreateChargeRequest({
    required this.amount,
    this.currency = 'NGN',
    required this.reference,
    required this.customerId,
    this.meta,
    required this.paymentMethodId,
    this.redirectUrl,
    this.authorization,
    this.recurring = false,
    this.orderId,
    this.merchantVatAmount,
  });

  Map<String, dynamic> toJson() => _$CreateChargeRequestToJson(this);
}