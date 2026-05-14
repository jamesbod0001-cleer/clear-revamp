import 'package:freezed_annotation/freezed_annotation.dart';

part 'ussd_object.g.dart';

@JsonSerializable()
class USSDObject {
  @JsonKey(name: 'account_bank')
  final String accountBank;

  USSDObject({required this.accountBank});

  factory USSDObject.fromJson(Map<String, dynamic> json) =>
      _$USSDObjectFromJson(json);
  Map<String, dynamic> toJson() => _$USSDObjectToJson(this);
}
