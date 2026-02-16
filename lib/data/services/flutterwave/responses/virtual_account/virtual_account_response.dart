import 'package:freezed_annotation/freezed_annotation.dart';

part 'virtual_account_response.g.dart';

@JsonSerializable()
class VirtualAccountResponse {
  final String? id;
  final double? amount;
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  final String? reference;
  @JsonKey(name: 'account_bank_name')
  final String? accountBankName;
  @JsonKey(name: 'account_type')
  final String? accountType;
  final String? status;
  @JsonKey(name: 'account_expiration_datetime')
  final DateTime accountExpirationDatetime;
  final String? note;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @JsonKey(name: 'created_datetime')
  final DateTime? createdDatetime;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'customer_reference')
  final String? customerReference;
  final String? currency;

  VirtualAccountResponse({
    required this.id,
    required this.amount,
    required this.accountNumber,
    required this.reference,
    required this.accountBankName,
    required this.accountType,
    required this.status,
    required this.accountExpirationDatetime,
    required this.note,
    required this.customerId,
    required this.createdDatetime,
    this.meta,
    required this.customerReference,
    required this.currency,
  });

  factory VirtualAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$VirtualAccountResponseFromJson(json);
}
