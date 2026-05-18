import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_response.g.dart';

@JsonSerializable()
class BankResponse {
  final String id;
  final String code;
  final String name;

  BankResponse({required this.id, required this.code, required this.name});

  factory BankResponse.fromJson(Map<String, dynamic> json) =>
      _$BankResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BankResponseToJson(this);
}
