/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Payout type in your schema. */
class Payout extends amplify_core.Model {
  static const classType = const _PayoutModelType();
  final String id;
  final String? _reference;
  final String? _flutterwaveId;
  final double? _amount;
  final String? _currency;
  final double? _fee;
  final PayoutStatus? _status;
  final String? _failureReason;
  final String? _narration;
  final List<String>? _participants;
  final Agreement? _agreement;
  final Milestone? _milestone;
  final PayoutDestination? _payoutDestination;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  PayoutModelIdentifier get modelIdentifier {
      return PayoutModelIdentifier(
        id: id
      );
  }
  
  String get reference {
    try {
      return _reference!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get flutterwaveId {
    return _flutterwaveId;
  }
  
  double get amount {
    try {
      return _amount!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get currency {
    try {
      return _currency!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double? get fee {
    return _fee;
  }
  
  PayoutStatus? get status {
    return _status;
  }
  
  String? get failureReason {
    return _failureReason;
  }
  
  String? get narration {
    return _narration;
  }
  
  List<String>? get participants {
    return _participants;
  }
  
  Agreement? get agreement {
    return _agreement;
  }
  
  Milestone? get milestone {
    return _milestone;
  }
  
  PayoutDestination? get payoutDestination {
    return _payoutDestination;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Payout._internal({required this.id, required reference, flutterwaveId, required amount, required currency, fee, status, failureReason, narration, participants, agreement, milestone, payoutDestination, createdAt, updatedAt}): _reference = reference, _flutterwaveId = flutterwaveId, _amount = amount, _currency = currency, _fee = fee, _status = status, _failureReason = failureReason, _narration = narration, _participants = participants, _agreement = agreement, _milestone = milestone, _payoutDestination = payoutDestination, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Payout({String? id, required String reference, String? flutterwaveId, required double amount, required String currency, double? fee, PayoutStatus? status, String? failureReason, String? narration, List<String>? participants, Agreement? agreement, Milestone? milestone, PayoutDestination? payoutDestination}) {
    return Payout._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      reference: reference,
      flutterwaveId: flutterwaveId,
      amount: amount,
      currency: currency,
      fee: fee,
      status: status,
      failureReason: failureReason,
      narration: narration,
      participants: participants != null ? List<String>.unmodifiable(participants) : participants,
      agreement: agreement,
      milestone: milestone,
      payoutDestination: payoutDestination);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Payout &&
      id == other.id &&
      _reference == other._reference &&
      _flutterwaveId == other._flutterwaveId &&
      _amount == other._amount &&
      _currency == other._currency &&
      _fee == other._fee &&
      _status == other._status &&
      _failureReason == other._failureReason &&
      _narration == other._narration &&
      DeepCollectionEquality().equals(_participants, other._participants) &&
      _agreement == other._agreement &&
      _milestone == other._milestone &&
      _payoutDestination == other._payoutDestination;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Payout {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("reference=" + "$_reference" + ", ");
    buffer.write("flutterwaveId=" + "$_flutterwaveId" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("currency=" + "$_currency" + ", ");
    buffer.write("fee=" + (_fee != null ? _fee!.toString() : "null") + ", ");
    buffer.write("status=" + (_status != null ? amplify_core.enumToString(_status)! : "null") + ", ");
    buffer.write("failureReason=" + "$_failureReason" + ", ");
    buffer.write("narration=" + "$_narration" + ", ");
    buffer.write("participants=" + (_participants != null ? _participants!.toString() : "null") + ", ");
    buffer.write("agreement=" + (_agreement != null ? _agreement!.toString() : "null") + ", ");
    buffer.write("milestone=" + (_milestone != null ? _milestone!.toString() : "null") + ", ");
    buffer.write("payoutDestination=" + (_payoutDestination != null ? _payoutDestination!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Payout copyWith({String? reference, String? flutterwaveId, double? amount, String? currency, double? fee, PayoutStatus? status, String? failureReason, String? narration, List<String>? participants, Agreement? agreement, Milestone? milestone, PayoutDestination? payoutDestination}) {
    return Payout._internal(
      id: id,
      reference: reference ?? this.reference,
      flutterwaveId: flutterwaveId ?? this.flutterwaveId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      narration: narration ?? this.narration,
      participants: participants ?? this.participants,
      agreement: agreement ?? this.agreement,
      milestone: milestone ?? this.milestone,
      payoutDestination: payoutDestination ?? this.payoutDestination);
  }
  
  Payout copyWithModelFieldValues({
    ModelFieldValue<String>? reference,
    ModelFieldValue<String?>? flutterwaveId,
    ModelFieldValue<double>? amount,
    ModelFieldValue<String>? currency,
    ModelFieldValue<double?>? fee,
    ModelFieldValue<PayoutStatus?>? status,
    ModelFieldValue<String?>? failureReason,
    ModelFieldValue<String?>? narration,
    ModelFieldValue<List<String>?>? participants,
    ModelFieldValue<Agreement?>? agreement,
    ModelFieldValue<Milestone?>? milestone,
    ModelFieldValue<PayoutDestination?>? payoutDestination
  }) {
    return Payout._internal(
      id: id,
      reference: reference == null ? this.reference : reference.value,
      flutterwaveId: flutterwaveId == null ? this.flutterwaveId : flutterwaveId.value,
      amount: amount == null ? this.amount : amount.value,
      currency: currency == null ? this.currency : currency.value,
      fee: fee == null ? this.fee : fee.value,
      status: status == null ? this.status : status.value,
      failureReason: failureReason == null ? this.failureReason : failureReason.value,
      narration: narration == null ? this.narration : narration.value,
      participants: participants == null ? this.participants : participants.value,
      agreement: agreement == null ? this.agreement : agreement.value,
      milestone: milestone == null ? this.milestone : milestone.value,
      payoutDestination: payoutDestination == null ? this.payoutDestination : payoutDestination.value
    );
  }
  
  Payout.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _reference = json['reference'],
      _flutterwaveId = json['flutterwaveId'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _currency = json['currency'],
      _fee = (json['fee'] as num?)?.toDouble(),
      _status = amplify_core.enumFromString<PayoutStatus>(json['status'], PayoutStatus.values),
      _failureReason = json['failureReason'],
      _narration = json['narration'],
      _participants = json['participants']?.cast<String>(),
      _agreement = json['agreement'] != null
        ? json['agreement']['serializedData'] != null
          ? Agreement.fromJson(new Map<String, dynamic>.from(json['agreement']['serializedData']))
          : Agreement.fromJson(new Map<String, dynamic>.from(json['agreement']))
        : null,
      _milestone = json['milestone'] != null
        ? json['milestone']['serializedData'] != null
          ? Milestone.fromJson(new Map<String, dynamic>.from(json['milestone']['serializedData']))
          : Milestone.fromJson(new Map<String, dynamic>.from(json['milestone']))
        : null,
      _payoutDestination = json['payoutDestination'] != null
        ? json['payoutDestination']['serializedData'] != null
          ? PayoutDestination.fromJson(new Map<String, dynamic>.from(json['payoutDestination']['serializedData']))
          : PayoutDestination.fromJson(new Map<String, dynamic>.from(json['payoutDestination']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'reference': _reference, 'flutterwaveId': _flutterwaveId, 'amount': _amount, 'currency': _currency, 'fee': _fee, 'status': amplify_core.enumToString(_status), 'failureReason': _failureReason, 'narration': _narration, 'participants': _participants, 'agreement': _agreement?.toJson(), 'milestone': _milestone?.toJson(), 'payoutDestination': _payoutDestination?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'reference': _reference,
    'flutterwaveId': _flutterwaveId,
    'amount': _amount,
    'currency': _currency,
    'fee': _fee,
    'status': _status,
    'failureReason': _failureReason,
    'narration': _narration,
    'participants': _participants,
    'agreement': _agreement,
    'milestone': _milestone,
    'payoutDestination': _payoutDestination,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PayoutModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PayoutModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final REFERENCE = amplify_core.QueryField(fieldName: "reference");
  static final FLUTTERWAVEID = amplify_core.QueryField(fieldName: "flutterwaveId");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final CURRENCY = amplify_core.QueryField(fieldName: "currency");
  static final FEE = amplify_core.QueryField(fieldName: "fee");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final FAILUREREASON = amplify_core.QueryField(fieldName: "failureReason");
  static final NARRATION = amplify_core.QueryField(fieldName: "narration");
  static final PARTICIPANTS = amplify_core.QueryField(fieldName: "participants");
  static final AGREEMENT = amplify_core.QueryField(
    fieldName: "agreement",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Agreement'));
  static final MILESTONE = amplify_core.QueryField(
    fieldName: "milestone",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Milestone'));
  static final PAYOUTDESTINATION = amplify_core.QueryField(
    fieldName: "payoutDestination",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'PayoutDestination'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Payout";
    modelSchemaDefinition.pluralName = "Payouts";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "participants",
        identityClaim: "sub",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.REFERENCE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.FLUTTERWAVEID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.AMOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.CURRENCY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.FEE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.FAILUREREASON,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.NARRATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payout.PARTICIPANTS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Payout.AGREEMENT,
      isRequired: false,
      targetNames: ['agreementId'],
      ofModelName: 'Agreement'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Payout.MILESTONE,
      isRequired: false,
      targetNames: ['milestoneId'],
      ofModelName: 'Milestone'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Payout.PAYOUTDESTINATION,
      isRequired: false,
      targetNames: ['recipientAccountNumber', 'recipientBankCode'],
      ofModelName: 'PayoutDestination'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _PayoutModelType extends amplify_core.ModelType<Payout> {
  const _PayoutModelType();
  
  @override
  Payout fromJson(Map<String, dynamic> jsonData) {
    return Payout.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Payout';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Payout] in your schema.
 */
class PayoutModelIdentifier implements amplify_core.ModelIdentifier<Payout> {
  final String id;

  /** Create an instance of PayoutModelIdentifier using [id] the primary key. */
  const PayoutModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'PayoutModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PayoutModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}