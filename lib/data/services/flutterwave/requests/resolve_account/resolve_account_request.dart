import 'package:freezed_annotation/freezed_annotation.dart';

part 'resolve_account_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ResolveAccountRequest {
  final String currency;
  final AccountObject account;

  ResolveAccountRequest({this.currency = 'NGN',required this.account});

  Map<String, dynamic> toJson() => _$ResolveAccountRequestToJson(this);
}

@JsonSerializable()
class AccountObject {
  final String code;
  final String number;

  AccountObject({required this.code, required this.number});

  factory AccountObject.fromJson(Map<String, dynamic> json) =>
      _$AccountObjectFromJson(json);
  Map<String, dynamic> toJson() => _$AccountObjectToJson(this);
}
