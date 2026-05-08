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


/** This is an auto generated class representing the Transaction type in your schema. */
class Transaction extends amplify_core.Model {
  static const classType = const _TransactionModelType();
  final String id;
  final TransactionPaymentMethodType? _paymentMethodType;
  final String? _reference;
  final String? _flutterwaveId;
  final double? _amount;
  final String? _currency;
  final TransactionStatus? _status;
  final String? _flutterwavePaymentMethodId;
  final Agreement? _agreement;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  TransactionModelIdentifier get modelIdentifier {
      return TransactionModelIdentifier(
        id: id
      );
  }
  
  TransactionPaymentMethodType? get paymentMethodType {
    return _paymentMethodType;
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
  
  String get flutterwaveId {
    try {
      return _flutterwaveId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  TransactionStatus? get status {
    return _status;
  }
  
  String? get flutterwavePaymentMethodId {
    return _flutterwavePaymentMethodId;
  }
  
  Agreement? get agreement {
    return _agreement;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Transaction._internal({required this.id, paymentMethodType, required reference, required flutterwaveId, required amount, required currency, status, flutterwavePaymentMethodId, agreement, createdAt, updatedAt}): _paymentMethodType = paymentMethodType, _reference = reference, _flutterwaveId = flutterwaveId, _amount = amount, _currency = currency, _status = status, _flutterwavePaymentMethodId = flutterwavePaymentMethodId, _agreement = agreement, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Transaction({String? id, TransactionPaymentMethodType? paymentMethodType, required String reference, required String flutterwaveId, required double amount, required String currency, TransactionStatus? status, String? flutterwavePaymentMethodId, Agreement? agreement}) {
    return Transaction._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      paymentMethodType: paymentMethodType,
      reference: reference,
      flutterwaveId: flutterwaveId,
      amount: amount,
      currency: currency,
      status: status,
      flutterwavePaymentMethodId: flutterwavePaymentMethodId,
      agreement: agreement);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction &&
      id == other.id &&
      _paymentMethodType == other._paymentMethodType &&
      _reference == other._reference &&
      _flutterwaveId == other._flutterwaveId &&
      _amount == other._amount &&
      _currency == other._currency &&
      _status == other._status &&
      _flutterwavePaymentMethodId == other._flutterwavePaymentMethodId &&
      _agreement == other._agreement;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Transaction {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("paymentMethodType=" + (_paymentMethodType != null ? amplify_core.enumToString(_paymentMethodType)! : "null") + ", ");
    buffer.write("reference=" + "$_reference" + ", ");
    buffer.write("flutterwaveId=" + "$_flutterwaveId" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("currency=" + "$_currency" + ", ");
    buffer.write("status=" + (_status != null ? amplify_core.enumToString(_status)! : "null") + ", ");
    buffer.write("flutterwavePaymentMethodId=" + "$_flutterwavePaymentMethodId" + ", ");
    buffer.write("agreement=" + (_agreement != null ? _agreement!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Transaction copyWith({TransactionPaymentMethodType? paymentMethodType, String? reference, String? flutterwaveId, double? amount, String? currency, TransactionStatus? status, String? flutterwavePaymentMethodId, Agreement? agreement}) {
    return Transaction._internal(
      id: id,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      reference: reference ?? this.reference,
      flutterwaveId: flutterwaveId ?? this.flutterwaveId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      flutterwavePaymentMethodId: flutterwavePaymentMethodId ?? this.flutterwavePaymentMethodId,
      agreement: agreement ?? this.agreement);
  }
  
  Transaction copyWithModelFieldValues({
    ModelFieldValue<TransactionPaymentMethodType?>? paymentMethodType,
    ModelFieldValue<String>? reference,
    ModelFieldValue<String>? flutterwaveId,
    ModelFieldValue<double>? amount,
    ModelFieldValue<String>? currency,
    ModelFieldValue<TransactionStatus?>? status,
    ModelFieldValue<String?>? flutterwavePaymentMethodId,
    ModelFieldValue<Agreement?>? agreement
  }) {
    return Transaction._internal(
      id: id,
      paymentMethodType: paymentMethodType == null ? this.paymentMethodType : paymentMethodType.value,
      reference: reference == null ? this.reference : reference.value,
      flutterwaveId: flutterwaveId == null ? this.flutterwaveId : flutterwaveId.value,
      amount: amount == null ? this.amount : amount.value,
      currency: currency == null ? this.currency : currency.value,
      status: status == null ? this.status : status.value,
      flutterwavePaymentMethodId: flutterwavePaymentMethodId == null ? this.flutterwavePaymentMethodId : flutterwavePaymentMethodId.value,
      agreement: agreement == null ? this.agreement : agreement.value
    );
  }
  
  Transaction.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _paymentMethodType = amplify_core.enumFromString<TransactionPaymentMethodType>(json['paymentMethodType'], TransactionPaymentMethodType.values),
      _reference = json['reference'],
      _flutterwaveId = json['flutterwaveId'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _currency = json['currency'],
      _status = amplify_core.enumFromString<TransactionStatus>(json['status'], TransactionStatus.values),
      _flutterwavePaymentMethodId = json['flutterwavePaymentMethodId'],
      _agreement = json['agreement'] != null
        ? json['agreement']['serializedData'] != null
          ? Agreement.fromJson(new Map<String, dynamic>.from(json['agreement']['serializedData']))
          : Agreement.fromJson(new Map<String, dynamic>.from(json['agreement']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'paymentMethodType': amplify_core.enumToString(_paymentMethodType), 'reference': _reference, 'flutterwaveId': _flutterwaveId, 'amount': _amount, 'currency': _currency, 'status': amplify_core.enumToString(_status), 'flutterwavePaymentMethodId': _flutterwavePaymentMethodId, 'agreement': _agreement?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'paymentMethodType': _paymentMethodType,
    'reference': _reference,
    'flutterwaveId': _flutterwaveId,
    'amount': _amount,
    'currency': _currency,
    'status': _status,
    'flutterwavePaymentMethodId': _flutterwavePaymentMethodId,
    'agreement': _agreement,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<TransactionModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<TransactionModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final PAYMENTMETHODTYPE = amplify_core.QueryField(fieldName: "paymentMethodType");
  static final REFERENCE = amplify_core.QueryField(fieldName: "reference");
  static final FLUTTERWAVEID = amplify_core.QueryField(fieldName: "flutterwaveId");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final CURRENCY = amplify_core.QueryField(fieldName: "currency");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final FLUTTERWAVEPAYMENTMETHODID = amplify_core.QueryField(fieldName: "flutterwavePaymentMethodId");
  static final AGREEMENT = amplify_core.QueryField(
    fieldName: "agreement",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Agreement'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Transaction";
    modelSchemaDefinition.pluralName = "Transactions";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
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
      key: Transaction.PAYMENTMETHODTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Transaction.REFERENCE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Transaction.FLUTTERWAVEID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Transaction.AMOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Transaction.CURRENCY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Transaction.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Transaction.FLUTTERWAVEPAYMENTMETHODID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Transaction.AGREEMENT,
      isRequired: false,
      targetNames: ['agreementId'],
      ofModelName: 'Agreement'
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

class _TransactionModelType extends amplify_core.ModelType<Transaction> {
  const _TransactionModelType();
  
  @override
  Transaction fromJson(Map<String, dynamic> jsonData) {
    return Transaction.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Transaction';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Transaction] in your schema.
 */
class TransactionModelIdentifier implements amplify_core.ModelIdentifier<Transaction> {
  final String id;

  /** Create an instance of TransactionModelIdentifier using [id] the primary key. */
  const TransactionModelIdentifier({
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
  String toString() => 'TransactionModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is TransactionModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}