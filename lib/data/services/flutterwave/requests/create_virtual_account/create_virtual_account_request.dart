import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_virtual_account_request.g.dart';

@JsonSerializable()
class CreateVirtualAccountRequest {
  final String reference;
  @JsonKey(name: 'customer_id')
  final String customerId;
  final double amount;
  final int? expiry;
  final String currency;
  @JsonKey(name: 'account_type')
  final String accountType;
  final Map<String, dynamic>? meta;
  final String? narration;
  final String? bvn;
  final String? nin;
  @JsonKey(name: 'customer_account_number')
  final String? customerAccountNumber;
  @JsonKey(name: 'merchant_vat_amount')
  final String? merchantVatAmount;

  CreateVirtualAccountRequest({
    required this.reference,
    required this.customerId,
    required this.amount,
    this.expiry,
    this.currency = 'NGN',
    required this.accountType,
    this.meta,
    this.narration,
    this.bvn,
    this.nin,
    this.customerAccountNumber,
    this.merchantVatAmount,
  });

  Map<String, dynamic> toJson() => _$CreateVirtualAccountRequestToJson(this);
}
