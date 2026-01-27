import 'package:freezed_annotation/freezed_annotation.dart';

part 'resolve_account_response.g.dart';

@JsonSerializable()
class ResolveAccountResponse {
  @JsonKey(name: 'bank_code')
  final String bankCode;
  @JsonKey(name: 'account_number')
  final String accountNumber;
  @JsonKey(name: 'account_name')
  final String accountName;

  ResolveAccountResponse({
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
  });

  factory ResolveAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$ResolveAccountResponseFromJson(json);
}
