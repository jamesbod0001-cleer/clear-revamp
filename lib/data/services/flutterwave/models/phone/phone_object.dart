import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone_object.g.dart';

@JsonSerializable()
class PhoneObject {
  @JsonKey(name: 'country_code')
  final String countryCode;
  final String number;

  PhoneObject({required this.countryCode, required this.number});

  factory PhoneObject.fromJson(Map<String, dynamic> json) =>
      _$PhoneObjectFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneObjectToJson(this);
}
