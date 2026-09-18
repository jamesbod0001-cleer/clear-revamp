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


/** This is an auto generated class representing the Refund type in your schema. */
class Refund extends amplify_core.Model {
  static const classType = const _RefundModelType();
  final String id;
  final String? _chargeId;
  final String? _flutterwaveRefundId;
  final double? _amount;
  final String? _currency;
  final String? _reason;
  final RefundStatus? _status;
  final String? _failureReason;
  final List<String>? _participants;
  final Agreement? _agreement;
  final Transaction? _transaction;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  RefundModelIdentifier get modelIdentifier {
      return RefundModelIdentifier(
        id: id
      );
  }
  
  String get chargeId {
    try {
      return _chargeId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get flutterwaveRefundId {
    return _flutterwaveRefundId;
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
  
  String? get reason {
    return _reason;
  }
  
  RefundStatus? get status {
    return _status;
  }
  
  String? get failureReason {
    return _failureReason;
  }
  
  List<String>? get participants {
    return _participants;
  }
  
  Agreement? get agreement {
    return _agreement;
  }
  
  Transaction? get transaction {
    return _transaction;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Refund._internal({required this.id, required chargeId, flutterwaveRefundId, required amount, required currency, reason, status, failureReason, participants, agreement, transaction, createdAt, updatedAt}): _chargeId = chargeId, _flutterwaveRefundId = flutterwaveRefundId, _amount = amount, _currency = currency, _reason = reason, _status = status, _failureReason = failureReason, _participants = participants, _agreement = agreement, _transaction = transaction, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Refund({String? id, required String chargeId, String? flutterwaveRefundId, required double amount, required String currency, String? reason, RefundStatus? status, String? failureReason, List<String>? participants, Agreement? agreement, Transaction? transaction}) {
    return Refund._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      chargeId: chargeId,
      flutterwaveRefundId: flutterwaveRefundId,
      amount: amount,
      currency: currency,
      reason: reason,
      status: status,
      failureReason: failureReason,
      participants: participants != null ? List<String>.unmodifiable(participants) : participants,
      agreement: agreement,
      transaction: transaction);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Refund &&
      id == other.id &&
      _chargeId == other._chargeId &&
      _flutterwaveRefundId == other._flutterwaveRefundId &&
      _amount == other._amount &&
      _currency == other._currency &&
      _reason == other._reason &&
      _status == other._status &&
      _failureReason == other._failureReason &&
      DeepCollectionEquality().equals(_participants, other._participants) &&
      _agreement == other._agreement &&
      _transaction == other._transaction;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Refund {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("chargeId=" + "$_chargeId" + ", ");
    buffer.write("flutterwaveRefundId=" + "$_flutterwaveRefundId" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("currency=" + "$_currency" + ", ");
    buffer.write("reason=" + "$_reason" + ", ");
    buffer.write("status=" + (_status != null ? amplify_core.enumToString(_status)! : "null") + ", ");
    buffer.write("failureReason=" + "$_failureReason" + ", ");
    buffer.write("participants=" + (_participants != null ? _participants!.toString() : "null") + ", ");
    buffer.write("agreement=" + (_agreement != null ? _agreement!.toString() : "null") + ", ");
    buffer.write("transaction=" + (_transaction != null ? _transaction!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Refund copyWith({String? chargeId, String? flutterwaveRefundId, double? amount, String? currency, String? reason, RefundStatus? status, String? failureReason, List<String>? participants, Agreement? agreement, Transaction? transaction}) {
    return Refund._internal(
      id: id,
      chargeId: chargeId ?? this.chargeId,
      flutterwaveRefundId: flutterwaveRefundId ?? this.flutterwaveRefundId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      participants: participants ?? this.participants,
      agreement: agreement ?? this.agreement,
      transaction: transaction ?? this.transaction);
  }
  
  Refund copyWithModelFieldValues({
    ModelFieldValue<String>? chargeId,
    ModelFieldValue<String?>? flutterwaveRefundId,
    ModelFieldValue<double>? amount,
    ModelFieldValue<String>? currency,
    ModelFieldValue<String?>? reason,
    ModelFieldValue<RefundStatus?>? status,
    ModelFieldValue<String?>? failureReason,
    ModelFieldValue<List<String>?>? participants,
    ModelFieldValue<Agreement?>? agreement,
    ModelFieldValue<Transaction?>? transaction
  }) {
    return Refund._internal(
      id: id,
      chargeId: chargeId == null ? this.chargeId : chargeId.value,
      flutterwaveRefundId: flutterwaveRefundId == null ? this.flutterwaveRefundId : flutterwaveRefundId.value,
      amount: amount == null ? this.amount : amount.value,
      currency: currency == null ? this.currency : currency.value,
      reason: reason == null ? this.reason : reason.value,
      status: status == null ? this.status : status.value,
      failureReason: failureReason == null ? this.failureReason : failureReason.value,
      participants: participants == null ? this.participants : participants.value,
      agreement: agreement == null ? this.agreement : agreement.value,
      transaction: transaction == null ? this.transaction : transaction.value
    );
  }
  
  Refund.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _chargeId = json['chargeId'],
      _flutterwaveRefundId = json['flutterwaveRefundId'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _currency = json['currency'],
      _reason = json['reason'],
      _status = amplify_core.enumFromString<RefundStatus>(json['status'], RefundStatus.values),
      _failureReason = json['failureReason'],
      _participants = json['participants']?.cast<String>(),
      _agreement = json['agreement'] != null
        ? json['agreement']['serializedData'] != null
          ? Agreement.fromJson(new Map<String, dynamic>.from(json['agreement']['serializedData']))
          : Agreement.fromJson(new Map<String, dynamic>.from(json['agreement']))
        : null,
      _transaction = json['transaction'] != null
        ? json['transaction']['serializedData'] != null
          ? Transaction.fromJson(new Map<String, dynamic>.from(json['transaction']['serializedData']))
          : Transaction.fromJson(new Map<String, dynamic>.from(json['transaction']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'chargeId': _chargeId, 'flutterwaveRefundId': _flutterwaveRefundId, 'amount': _amount, 'currency': _currency, 'reason': _reason, 'status': amplify_core.enumToString(_status), 'failureReason': _failureReason, 'participants': _participants, 'agreement': _agreement?.toJson(), 'transaction': _transaction?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'chargeId': _chargeId,
    'flutterwaveRefundId': _flutterwaveRefundId,
    'amount': _amount,
    'currency': _currency,
    'reason': _reason,
    'status': _status,
    'failureReason': _failureReason,
    'participants': _participants,
    'agreement': _agreement,
    'transaction': _transaction,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<RefundModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RefundModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CHARGEID = amplify_core.QueryField(fieldName: "chargeId");
  static final FLUTTERWAVEREFUNDID = amplify_core.QueryField(fieldName: "flutterwaveRefundId");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final CURRENCY = amplify_core.QueryField(fieldName: "currency");
  static final REASON = amplify_core.QueryField(fieldName: "reason");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final FAILUREREASON = amplify_core.QueryField(fieldName: "failureReason");
  static final PARTICIPANTS = amplify_core.QueryField(fieldName: "participants");
  static final AGREEMENT = amplify_core.QueryField(
    fieldName: "agreement",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Agreement'));
  static final TRANSACTION = amplify_core.QueryField(
    fieldName: "transaction",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Transaction'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Refund";
    modelSchemaDefinition.pluralName = "Refunds";
    
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
      key: Refund.CHARGEID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Refund.FLUTTERWAVEREFUNDID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Refund.AMOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Refund.CURRENCY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Refund.REASON,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Refund.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Refund.FAILUREREASON,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Refund.PARTICIPANTS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Refund.AGREEMENT,
      isRequired: false,
      targetNames: ['agreementId'],
      ofModelName: 'Agreement'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Refund.TRANSACTION,
      isRequired: false,
      targetNames: ['transactionId'],
      ofModelName: 'Transaction'
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

class _RefundModelType extends amplify_core.ModelType<Refund> {
  const _RefundModelType();
  
  @override
  Refund fromJson(Map<String, dynamic> jsonData) {
    return Refund.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Refund';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Refund] in your schema.
 */
class RefundModelIdentifier implements amplify_core.ModelIdentifier<Refund> {
  final String id;

  /** Create an instance of RefundModelIdentifier using [id] the primary key. */
  const RefundModelIdentifier({
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
  String toString() => 'RefundModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is RefundModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}