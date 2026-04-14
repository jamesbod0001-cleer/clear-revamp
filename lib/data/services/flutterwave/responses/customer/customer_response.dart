import 'package:cleer/data/services/flutterwave/models/address/address_object.dart';
import 'package:cleer/data/services/flutterwave/models/name/name_object.dart';
import 'package:cleer/data/services/flutterwave/models/phone/phone_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_response.g.dart';

@JsonSerializable()
class CustomerResponse {
  final String id;
  final AddressObject? address;
  final String email;
  final NameObject name;
  final PhoneObject phone;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'created_datetime')
  final DateTime createdDatetime;

  CustomerResponse({
    required this.id,
    this.address,
    required this.email,
    required this.name,
    required this.phone,
    this.meta,
    required this.createdDatetime,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerResponseToJson(this);

}