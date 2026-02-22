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


/** This is an auto generated class representing the Agreement type in your schema. */
class Agreement extends amplify_core.Model {
  static const classType = const _AgreementModelType();
  final String id;
  final double? _amount;
  final String? _currency;
  final AgreementDisbursementType? _disbursementType;
  final String? _category;
  final amplify_core.TemporalDate? _expectedReleaseDate;
  final String? _description;
  final AgreementInitiatorRole? _initiatorRole;
  final AgreementStatus? _status;
  final List<Milestone>? _milestones;
  final User? _initiator;
  final User? _sender;
  final User? _recipient;
  final PayoutDestination? _payoutDestination;
  final List<Transaction>? _transactions;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  AgreementModelIdentifier get modelIdentifier {
      return AgreementModelIdentifier(
        id: id
      );
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
  
  AgreementDisbursementType? get disbursementType {
    return _disbursementType;
  }
  
  String get category {
    try {
      return _category!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDate get expectedReleaseDate {
    try {
      return _expectedReleaseDate!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get description {
    try {
      return _description!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  AgreementInitiatorRole? get initiatorRole {
    return _initiatorRole;
  }
  
  AgreementStatus? get status {
    return _status;
  }
  
  List<Milestone>? get milestones {
    return _milestones;
  }
  
  User? get initiator {
    return _initiator;
  }
  
  User? get sender {
    return _sender;
  }
  
  User? get recipient {
    return _recipient;
  }
  
  PayoutDestination? get payoutDestination {
    return _payoutDestination;
  }
  
  List<Transaction>? get transactions {
    return _transactions;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Agreement._internal({required this.id, required amount, required currency, disbursementType, required category, required expectedReleaseDate, required description, initiatorRole, status, milestones, initiator, sender, recipient, payoutDestination, transactions, createdAt, updatedAt}): _amount = amount, _currency = currency, _disbursementType = disbursementType, _category = category, _expectedReleaseDate = expectedReleaseDate, _description = description, _initiatorRole = initiatorRole, _status = status, _milestones = milestones, _initiator = initiator, _sender = sender, _recipient = recipient, _payoutDestination = payoutDestination, _transactions = transactions, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Agreement({String? id, required double amount, required String currency, AgreementDisbursementType? disbursementType, required String category, required amplify_core.TemporalDate expectedReleaseDate, required String description, AgreementInitiatorRole? initiatorRole, AgreementStatus? status, List<Milestone>? milestones, User? initiator, User? sender, User? recipient, PayoutDestination? payoutDestination, List<Transaction>? transactions}) {
    return Agreement._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      amount: amount,
      currency: currency,
      disbursementType: disbursementType,
      category: category,
      expectedReleaseDate: expectedReleaseDate,
      description: description,
      initiatorRole: initiatorRole,
      status: status,
      milestones: milestones != null ? List<Milestone>.unmodifiable(milestones) : milestones,
      initiator: initiator,
      sender: sender,
      recipient: recipient,
      payoutDestination: payoutDestination,
      transactions: transactions != null ? List<Transaction>.unmodifiable(transactions) : transactions);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Agreement &&
      id == other.id &&
      _amount == other._amount &&
      _currency == other._currency &&
      _disbursementType == other._disbursementType &&
      _category == other._category &&
      _expectedReleaseDate == other._expectedReleaseDate &&
      _description == other._description &&
      _initiatorRole == other._initiatorRole &&
      _status == other._status &&
      DeepCollectionEquality().equals(_milestones, other._milestones) &&
      _initiator == other._initiator &&
      _sender == other._sender &&
      _recipient == other._recipient &&
      _payoutDestination == other._payoutDestination &&
      DeepCollectionEquality().equals(_transactions, other._transactions);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Agreement {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("currency=" + "$_currency" + ", ");
    buffer.write("disbursementType=" + (_disbursementType != null ? amplify_core.enumToString(_disbursementType)! : "null") + ", ");
    buffer.write("category=" + "$_category" + ", ");
    buffer.write("expectedReleaseDate=" + (_expectedReleaseDate != null ? _expectedReleaseDate!.format() : "null") + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("initiatorRole=" + (_initiatorRole != null ? amplify_core.enumToString(_initiatorRole)! : "null") + ", ");
    buffer.write("status=" + (_status != null ? amplify_core.enumToString(_status)! : "null") + ", ");
    buffer.write("initiator=" + (_initiator != null ? _initiator!.toString() : "null") + ", ");
    buffer.write("sender=" + (_sender != null ? _sender!.toString() : "null") + ", ");
    buffer.write("recipient=" + (_recipient != null ? _recipient!.toString() : "null") + ", ");
    buffer.write("payoutDestination=" + (_payoutDestination != null ? _payoutDestination!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Agreement copyWith({double? amount, String? currency, AgreementDisbursementType? disbursementType, String? category, amplify_core.TemporalDate? expectedReleaseDate, String? description, AgreementInitiatorRole? initiatorRole, AgreementStatus? status, List<Milestone>? milestones, User? initiator, User? sender, User? recipient, PayoutDestination? payoutDestination, List<Transaction>? transactions}) {
    return Agreement._internal(
      id: id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      disbursementType: disbursementType ?? this.disbursementType,
      category: category ?? this.category,
      expectedReleaseDate: expectedReleaseDate ?? this.expectedReleaseDate,
      description: description ?? this.description,
      initiatorRole: initiatorRole ?? this.initiatorRole,
      status: status ?? this.status,
      milestones: milestones ?? this.milestones,
      initiator: initiator ?? this.initiator,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
      payoutDestination: payoutDestination ?? this.payoutDestination,
      transactions: transactions ?? this.transactions);
  }
  
  Agreement copyWithModelFieldValues({
    ModelFieldValue<double>? amount,
    ModelFieldValue<String>? currency,
    ModelFieldValue<AgreementDisbursementType?>? disbursementType,
    ModelFieldValue<String>? category,
    ModelFieldValue<amplify_core.TemporalDate>? expectedReleaseDate,
    ModelFieldValue<String>? description,
    ModelFieldValue<AgreementInitiatorRole?>? initiatorRole,
    ModelFieldValue<AgreementStatus?>? status,
    ModelFieldValue<List<Milestone>?>? milestones,
    ModelFieldValue<User?>? initiator,
    ModelFieldValue<User?>? sender,
    ModelFieldValue<User?>? recipient,
    ModelFieldValue<PayoutDestination?>? payoutDestination,
    ModelFieldValue<List<Transaction>?>? transactions
  }) {
    return Agreement._internal(
      id: id,
      amount: amount == null ? this.amount : amount.value,
      currency: currency == null ? this.currency : currency.value,
      disbursementType: disbursementType == null ? this.disbursementType : disbursementType.value,
      category: category == null ? this.category : category.value,
      expectedReleaseDate: expectedReleaseDate == null ? this.expectedReleaseDate : expectedReleaseDate.value,
      description: description == null ? this.description : description.value,
      initiatorRole: initiatorRole == null ? this.initiatorRole : initiatorRole.value,
      status: status == null ? this.status : status.value,
      milestones: milestones == null ? this.milestones : milestones.value,
      initiator: initiator == null ? this.initiator : initiator.value,
      sender: sender == null ? this.sender : sender.value,
      recipient: recipient == null ? this.recipient : recipient.value,
      payoutDestination: payoutDestination == null ? this.payoutDestination : payoutDestination.value,
      transactions: transactions == null ? this.transactions : transactions.value
    );
  }
  
  Agreement.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _currency = json['currency'],
      _disbursementType = amplify_core.enumFromString<AgreementDisbursementType>(json['disbursementType'], AgreementDisbursementType.values),
      _category = json['category'],
      _expectedReleaseDate = json['expectedReleaseDate'] != null ? amplify_core.TemporalDate.fromString(json['expectedReleaseDate']) : null,
      _description = json['description'],
      _initiatorRole = amplify_core.enumFromString<AgreementInitiatorRole>(json['initiatorRole'], AgreementInitiatorRole.values),
      _status = amplify_core.enumFromString<AgreementStatus>(json['status'], AgreementStatus.values),
      _milestones = json['milestones']  is Map
        ? (json['milestones']['items'] is List
          ? (json['milestones']['items'] as List)
              .where((e) => e != null)
              .map((e) => Milestone.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['milestones'] is List
          ? (json['milestones'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => Milestone.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _initiator = json['initiator'] != null
        ? json['initiator']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['initiator']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['initiator']))
        : null,
      _sender = json['sender'] != null
        ? json['sender']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['sender']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['sender']))
        : null,
      _recipient = json['recipient'] != null
        ? json['recipient']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['recipient']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['recipient']))
        : null,
      _payoutDestination = json['payoutDestination'] != null
        ? json['payoutDestination']['serializedData'] != null
          ? PayoutDestination.fromJson(new Map<String, dynamic>.from(json['payoutDestination']['serializedData']))
          : PayoutDestination.fromJson(new Map<String, dynamic>.from(json['payoutDestination']))
        : null,
      _transactions = json['transactions']  is Map
        ? (json['transactions']['items'] is List
          ? (json['transactions']['items'] as List)
              .where((e) => e != null)
              .map((e) => Transaction.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['transactions'] is List
          ? (json['transactions'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => Transaction.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'amount': _amount, 'currency': _currency, 'disbursementType': amplify_core.enumToString(_disbursementType), 'category': _category, 'expectedReleaseDate': _expectedReleaseDate?.format(), 'description': _description, 'initiatorRole': amplify_core.enumToString(_initiatorRole), 'status': amplify_core.enumToString(_status), 'milestones': _milestones?.map((Milestone? e) => e?.toJson()).toList(), 'initiator': _initiator?.toJson(), 'sender': _sender?.toJson(), 'recipient': _recipient?.toJson(), 'payoutDestination': _payoutDestination?.toJson(), 'transactions': _transactions?.map((Transaction? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'amount': _amount,
    'currency': _currency,
    'disbursementType': _disbursementType,
    'category': _category,
    'expectedReleaseDate': _expectedReleaseDate,
    'description': _description,
    'initiatorRole': _initiatorRole,
    'status': _status,
    'milestones': _milestones,
    'initiator': _initiator,
    'sender': _sender,
    'recipient': _recipient,
    'payoutDestination': _payoutDestination,
    'transactions': _transactions,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<AgreementModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<AgreementModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final CURRENCY = amplify_core.QueryField(fieldName: "currency");
  static final DISBURSEMENTTYPE = amplify_core.QueryField(fieldName: "disbursementType");
  static final CATEGORY = amplify_core.QueryField(fieldName: "category");
  static final EXPECTEDRELEASEDATE = amplify_core.QueryField(fieldName: "expectedReleaseDate");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final INITIATORROLE = amplify_core.QueryField(fieldName: "initiatorRole");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final MILESTONES = amplify_core.QueryField(
    fieldName: "milestones",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Milestone'));
  static final INITIATOR = amplify_core.QueryField(
    fieldName: "initiator",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final SENDER = amplify_core.QueryField(
    fieldName: "sender",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final RECIPIENT = amplify_core.QueryField(
    fieldName: "recipient",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final PAYOUTDESTINATION = amplify_core.QueryField(
    fieldName: "payoutDestination",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'PayoutDestination'));
  static final TRANSACTIONS = amplify_core.QueryField(
    fieldName: "transactions",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Transaction'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Agreement";
    modelSchemaDefinition.pluralName = "Agreements";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.AMOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.CURRENCY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.DISBURSEMENTTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.CATEGORY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.EXPECTEDRELEASEDATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.DESCRIPTION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.INITIATORROLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Agreement.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Agreement.MILESTONES,
      isRequired: false,
      ofModelName: 'Milestone',
      associatedKey: Milestone.AGREEMENT
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Agreement.INITIATOR,
      isRequired: false,
      targetNames: ['initiatorId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Agreement.SENDER,
      isRequired: false,
      targetNames: ['senderId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Agreement.RECIPIENT,
      isRequired: false,
      targetNames: ['recipientId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Agreement.PAYOUTDESTINATION,
      isRequired: false,
      targetNames: ['recipientAccountNumber', 'recipientBankCode'],
      ofModelName: 'PayoutDestination'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Agreement.TRANSACTIONS,
      isRequired: false,
      ofModelName: 'Transaction',
      associatedKey: Transaction.AGREEMENT
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

class _AgreementModelType extends amplify_core.ModelType<Agreement> {
  const _AgreementModelType();
  
  @override
  Agreement fromJson(Map<String, dynamic> jsonData) {
    return Agreement.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Agreement';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Agreement] in your schema.
 */
class AgreementModelIdentifier implements amplify_core.ModelIdentifier<Agreement> {
  final String id;

  /** Create an instance of AgreementModelIdentifier using [id] the primary key. */
  const AgreementModelIdentifier({
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
  String toString() => 'AgreementModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is AgreementModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}