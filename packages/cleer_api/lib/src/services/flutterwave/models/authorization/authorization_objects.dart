import 'package:freezed_annotation/freezed_annotation.dart';

part 'authorization_objects.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthorizationObject {
  final String type;
  final OtpObject? otp;
  final PinObject? pin;

  AuthorizationObject({required this.type, this.otp, this.pin});

  factory AuthorizationObject.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationObjectFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorizationObjectToJson(this);
}

@JsonSerializable()
class OtpObject {
  final String code;

  OtpObject({required this.code});

  factory OtpObject.fromJson(Map<String, dynamic> json) =>
      _$OtpObjectFromJson(json);
  Map<String, dynamic> toJson() => _$OtpObjectToJson(this);
}

@JsonSerializable()
class PinObject {
  final String nonce;
  @JsonKey(name: 'encrypted_pin')
  final String encryptedPin;

  PinObject({required this.nonce, required this.encryptedPin});

  factory PinObject.fromJson(Map<String, dynamic> json) =>
      _$PinObjectFromJson(json);
  Map<String, dynamic> toJson() => _$PinObjectToJson(this);
}
