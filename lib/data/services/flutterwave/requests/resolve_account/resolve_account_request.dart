import 'package:freezed_annotation/freezed_annotation.dart';

part 'resolve_account_request.g.dart';

@JsonSerializable()
class ResolveAccountRequest {
  @JsonKey(name: 'bank_code')
  final String bankCode;
  @JsonKey(name: 'account_number')
  final String accountNumber;

  ResolveAccountRequest({
    required this.bankCode,
    required this.accountNumber,
  });


  Map<String, dynamic> toJson() => _$ResolveAccountRequestToJson(this);
}
