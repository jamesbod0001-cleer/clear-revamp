import 'package:cleer_api/src/services/api/models/flutterwave/models/name/name_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/models/phone/phone_object.dart';
import 'package:cleer_api/src/services/api/models/flutterwave/responses/payment_method/payment_method_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'charge_response.g.dart';

@JsonSerializable()
class ChargeResponse {
  final String? id;
  final double? amount;
  final List<FeeObject>? fees;
  @JsonKey(name: 'billing_details')
  final BillingDetailsObject? billingDetails;
  String? currency;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  final String? description;
  final bool? disputed;
  final bool? settled;
  @JsonKey(name: 'settlement_id')
  final List<String>? settlementId;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'next_action')
  final NextActionObject? nextAction;
  @JsonKey(name: 'payment_method_details')
  final PaymentMethodResponse? paymentMethodDetails;
  @JsonKey(name: 'redirect_url')
  final String? redirectUrl;
  final bool? refunded;
  final String? reference;
  final String? status; // succeeded, pending, failed, voided
  @JsonKey(name: 'processor_response')
  final ProcessorResponseObject? processorResponse;
  @JsonKey(name: 'created_datetime')
  final DateTime? createdDatetime;

  ChargeResponse({
    this.id,
    this.amount,
    this.fees,
    this.billingDetails,
    this.currency,
    this.customerId,
    this.description,
    this.disputed,
    this.settled,
    this.settlementId,
    this.meta,
    this.nextAction,
    this.paymentMethodDetails,
    this.redirectUrl,
    this.refunded,
    this.reference,
    this.status,
    this.processorResponse,
    this.createdDatetime,
  });

  factory ChargeResponse.fromJson(Map<String, dynamic> json) =>
      _$ChargeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChargeResponseToJson(this);
}

@JsonSerializable()
class FeeObject {
  final String? type;
  final double? amount;

  FeeObject({this.type, this.amount});

  factory FeeObject.fromJson(Map<String, dynamic> json) =>
      _$FeeObjectFromJson(json);
  Map<String, dynamic> toJson() => _$FeeObjectToJson(this);
}

@JsonSerializable()
class BillingDetailsObject {
  final String? email;
  final NameObject? name;
  final PhoneObject? phone;

  BillingDetailsObject({this.email, this.name, this.phone});

  factory BillingDetailsObject.fromJson(Map<String, dynamic> json) =>
      _$BillingDetailsObjectFromJson(json);
  Map<String, dynamic> toJson() => _$BillingDetailsObjectToJson(this);
}

@JsonSerializable()
class NextActionObject {
  final String type;
  @JsonKey(name: 'redirect_url')
  final RedirectUrlObject? redirectUrl;
  @JsonKey(name: 'requires_additional_fields')
  final RequiresAdditionalFieldsObject? requiresAdditionalFields;
  // Requires pin
  // Requires requery
  // Requires otp
  // Requires capture
  @JsonKey(name: 'payment_instruction')
  final PaymentInstructionObject? paymentInstruction;
  @JsonKey(name: 'requires_bank_transfer')
  final RequiresBankTransferObject? requiresBankTransfer;
  @JsonKey(name: 'qr_code')
  final QrCodeObject? qrCode;

  NextActionObject({
    required this.type,
    this.redirectUrl,
    this.requiresAdditionalFields,
    this.paymentInstruction,
    this.requiresBankTransfer,
    this.qrCode,
  });

  factory NextActionObject.fromJson(Map<String, dynamic> json) =>
      _$NextActionObjectFromJson(json);
  Map<String, dynamic> toJson() => _$NextActionObjectToJson(this);
}

@JsonSerializable()
class RedirectUrlObject {
  final String url;

  RedirectUrlObject({required this.url});

  factory RedirectUrlObject.fromJson(Map<String, dynamic> json) =>
      _$RedirectUrlObjectFromJson(json);
  Map<String, dynamic> toJson() => _$RedirectUrlObjectToJson(this);
}

@JsonSerializable()
class RequiresAdditionalFieldsObject {
  final List<String> fields;

  RequiresAdditionalFieldsObject({required this.fields});

  factory RequiresAdditionalFieldsObject.fromJson(Map<String, dynamic> json) =>
      _$RequiresAdditionalFieldsObjectFromJson(json);
  Map<String, dynamic> toJson() => _$RequiresAdditionalFieldsObjectToJson(this);
}

@JsonSerializable()
class PaymentInstructionObject {
  final String note;

  PaymentInstructionObject({required this.note});

  factory PaymentInstructionObject.fromJson(Map<String, dynamic> json) =>
      _$PaymentInstructionObjectFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentInstructionObjectToJson(this);
}

@JsonSerializable()
class RequiresBankTransferObject {
  @JsonKey(name: 'account_number')
  final String accountNumber;
  @JsonKey(name: 'account_bank_name')
  final String accountBankName;
  @JsonKey(name: 'account_expiration_datetime')
  final DateTime? accountExpirationDatetime;
  final String? note;

  RequiresBankTransferObject({
    required this.accountNumber,
    required this.accountBankName,
    this.accountExpirationDatetime,
    this.note,
  });

  factory RequiresBankTransferObject.fromJson(Map<String, dynamic> json) =>
      _$RequiresBankTransferObjectFromJson(json);
  Map<String, dynamic> toJson() => _$RequiresBankTransferObjectToJson(this);
}

@JsonSerializable()
class QrCodeObject {
  final String image;

  QrCodeObject({required this.image});

  factory QrCodeObject.fromJson(Map<String, dynamic> json) =>
      _$QrCodeObjectFromJson(json);
  Map<String, dynamic> toJson() => _$QrCodeObjectToJson(this);
}

@JsonSerializable()
class ProcessorResponseObject {
  final String type;
  final String code;

  ProcessorResponseObject({required this.type, required this.code});

  factory ProcessorResponseObject.fromJson(Map<String, dynamic> json) =>
      _$ProcessorResponseObjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessorResponseObjectToJson(this);
}
