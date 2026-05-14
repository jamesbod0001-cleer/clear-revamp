import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_object.g.dart';

@JsonSerializable()
class AddressObject {
  final String city;
  final String country;
  final String line1;
  final String? line2;
  @JsonKey(name: 'postal_code')
  final String postalCode;
  final String state;

  AddressObject({
    required this.city,
    required this.country,
    required this.line1,
    this.line2,
    required this.postalCode,
    required this.state,
  });

  factory AddressObject.fromJson(Map<String, dynamic> json) =>
      _$AddressObjectFromJson(json);
  Map<String, dynamic> toJson() => _$AddressObjectToJson(this);
}
