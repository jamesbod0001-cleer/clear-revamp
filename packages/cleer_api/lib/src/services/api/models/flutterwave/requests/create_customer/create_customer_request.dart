import 'package:cleer_api/src/services/api/models/flutterwave/models/address/address_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/name/name_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/phone/phone_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_customer_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateCustomerRequest {
  final String email;
  final NameObject name;
  final PhoneObject phone;
  final AddressObject? address;
  final Map<String, dynamic>? meta;

  CreateCustomerRequest({
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    this.meta,
  });

  Map<String, dynamic> toJson() => _$CreateCustomerRequestToJson(this);

  factory CreateCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCustomerRequestFromJson(json);
}
