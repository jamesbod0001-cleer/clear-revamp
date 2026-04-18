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


/** This is an auto generated class representing the AgreementPreview type in your schema. */
class AgreementPreview {
  final String? _shortCode;
  final double? _amount;
  final String? _currency;
  final String? _description;
  final String? _category;
  final String? _status;
  final String? _initiatorRole;
  final String? _disbursementType;
  final amplify_core.TemporalDate? _expectedReleaseDate;
  final UserPreview? _initiator;
  final UserPreview? _sender;
  final UserPreview? _recipient;
  final String? _recipientBankName;
  final String? _recipientAccountName;
  final String? _recipientAccountNumber;
  final List<MilestonePreview>? _milestones;

  String get shortCode {
    try {
      return _shortCode!;
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
  
  String? get status {
    return _status;
  }
  
  String? get initiatorRole {
    return _initiatorRole;
  }
  
  String? get disbursementType {
    return _disbursementType;
  }
  
  amplify_core.TemporalDate? get expectedReleaseDate {
    return _expectedReleaseDate;
  }
  
  UserPreview? get initiator {
    return _initiator;
  }
  
  UserPreview? get sender {
    return _sender;
  }
  
  UserPreview? get recipient {
    return _recipient;
  }
  
  String? get recipientBankName {
    return _recipientBankName;
  }
  
  String? get recipientAccountName {
    return _recipientAccountName;
  }
  
  String? get recipientAccountNumber {
    return _recipientAccountNumber;
  }
  
  List<MilestonePreview>? get milestones {
    return _milestones;
  }
  
  const AgreementPreview._internal({required shortCode, required amount, required currency, required description, required category, status, initiatorRole, disbursementType, expectedReleaseDate, initiator, sender, recipient, recipientBankName, recipientAccountName, recipientAccountNumber, milestones}): _shortCode = shortCode, _amount = amount, _currency = currency, _description = description, _category = category, _status = status, _initiatorRole = initiatorRole, _disbursementType = disbursementType, _expectedReleaseDate = expectedReleaseDate, _initiator = initiator, _sender = sender, _recipient = recipient, _recipientBankName = recipientBankName, _recipientAccountName = recipientAccountName, _recipientAccountNumber = recipientAccountNumber, _milestones = milestones;
  
  factory AgreementPreview({required String shortCode, required double amount, required String currency, required String description, required String category, String? status, String? initiatorRole, String? disbursementType, amplify_core.TemporalDate? expectedReleaseDate, UserPreview? initiator, UserPreview? sender, UserPreview? recipient, String? recipientBankName, String? recipientAccountName, String? recipientAccountNumber, List<MilestonePreview>? milestones}) {
    return AgreementPreview._internal(
      shortCode: shortCode,
      amount: amount,
      currency: currency,
      description: description,
      category: category,
      status: status,
      initiatorRole: initiatorRole,
      disbursementType: disbursementType,
      expectedReleaseDate: expectedReleaseDate,
      initiator: initiator,
      sender: sender,
      recipient: recipient,
      recipientBankName: recipientBankName,
      recipientAccountName: recipientAccountName,
      recipientAccountNumber: recipientAccountNumber,
      milestones: milestones != null ? List<MilestonePreview>.unmodifiable(milestones) : milestones);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgreementPreview &&
      _shortCode == other._shortCode &&
      _amount == other._amount &&
      _currency == other._currency &&
      _description == other._description &&
      _category == other._category &&
      _status == other._status &&
      _initiatorRole == other._initiatorRole &&
      _disbursementType == other._disbursementType &&
      _expectedReleaseDate == other._expectedReleaseDate &&
      _initiator == other._initiator &&
      _sender == other._sender &&
      _recipient == other._recipient &&
      _recipientBankName == other._recipientBankName &&
      _recipientAccountName == other._recipientAccountName &&
      _recipientAccountNumber == other._recipientAccountNumber &&
      DeepCollectionEquality().equals(_milestones, other._milestones);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("AgreementPreview {");
    buffer.write("shortCode=" + "$_shortCode" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("currency=" + "$_currency" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("category=" + "$_category" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("initiatorRole=" + "$_initiatorRole" + ", ");
    buffer.write("disbursementType=" + "$_disbursementType" + ", ");
    buffer.write("expectedReleaseDate=" + (_expectedReleaseDate != null ? _expectedReleaseDate!.format() : "null") + ", ");
    buffer.write("initiator=" + (_initiator != null ? _initiator!.toString() : "null") + ", ");
    buffer.write("sender=" + (_sender != null ? _sender!.toString() : "null") + ", ");
    buffer.write("recipient=" + (_recipient != null ? _recipient!.toString() : "null") + ", ");
    buffer.write("recipientBankName=" + "$_recipientBankName" + ", ");
    buffer.write("recipientAccountName=" + "$_recipientAccountName" + ", ");
    buffer.write("recipientAccountNumber=" + "$_recipientAccountNumber" + ", ");
    buffer.write("milestones=" + (_milestones != null ? _milestones!.toString() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  AgreementPreview copyWith({String? shortCode, double? amount, String? currency, String? description, String? category, String? status, String? initiatorRole, String? disbursementType, amplify_core.TemporalDate? expectedReleaseDate, UserPreview? initiator, UserPreview? sender, UserPreview? recipient, String? recipientBankName, String? recipientAccountName, String? recipientAccountNumber, List<MilestonePreview>? milestones}) {
    return AgreementPreview._internal(
      shortCode: shortCode ?? this.shortCode,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      initiatorRole: initiatorRole ?? this.initiatorRole,
      disbursementType: disbursementType ?? this.disbursementType,
      expectedReleaseDate: expectedReleaseDate ?? this.expectedReleaseDate,
      initiator: initiator ?? this.initiator,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
      recipientBankName: recipientBankName ?? this.recipientBankName,
      recipientAccountName: recipientAccountName ?? this.recipientAccountName,
      recipientAccountNumber: recipientAccountNumber ?? this.recipientAccountNumber,
      milestones: milestones ?? this.milestones);
  }
  
  AgreementPreview copyWithModelFieldValues({
    ModelFieldValue<String>? shortCode,
    ModelFieldValue<double>? amount,
    ModelFieldValue<String>? currency,
    ModelFieldValue<String>? description,
    ModelFieldValue<String>? category,
    ModelFieldValue<String?>? status,
    ModelFieldValue<String?>? initiatorRole,
    ModelFieldValue<String?>? disbursementType,
    ModelFieldValue<amplify_core.TemporalDate?>? expectedReleaseDate,
    ModelFieldValue<UserPreview?>? initiator,
    ModelFieldValue<UserPreview?>? sender,
    ModelFieldValue<UserPreview?>? recipient,
    ModelFieldValue<String?>? recipientBankName,
    ModelFieldValue<String?>? recipientAccountName,
    ModelFieldValue<String?>? recipientAccountNumber,
    ModelFieldValue<List<MilestonePreview>?>? milestones
  }) {
    return AgreementPreview._internal(
      shortCode: shortCode == null ? this.shortCode : shortCode.value,
      amount: amount == null ? this.amount : amount.value,
      currency: currency == null ? this.currency : currency.value,
      description: description == null ? this.description : description.value,
      category: category == null ? this.category : category.value,
      status: status == null ? this.status : status.value,
      initiatorRole: initiatorRole == null ? this.initiatorRole : initiatorRole.value,
      disbursementType: disbursementType == null ? this.disbursementType : disbursementType.value,
      expectedReleaseDate: expectedReleaseDate == null ? this.expectedReleaseDate : expectedReleaseDate.value,
      initiator: initiator == null ? this.initiator : initiator.value,
      sender: sender == null ? this.sender : sender.value,
      recipient: recipient == null ? this.recipient : recipient.value,
      recipientBankName: recipientBankName == null ? this.recipientBankName : recipientBankName.value,
      recipientAccountName: recipientAccountName == null ? this.recipientAccountName : recipientAccountName.value,
      recipientAccountNumber: recipientAccountNumber == null ? this.recipientAccountNumber : recipientAccountNumber.value,
      milestones: milestones == null ? this.milestones : milestones.value
    );
  }
  
  AgreementPreview.fromJson(Map<String, dynamic> json)  
    : _shortCode = json['shortCode'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _currency = json['currency'],
      _description = json['description'],
      _category = json['category'],
      _status = json['status'],
      _initiatorRole = json['initiatorRole'],
      _disbursementType = json['disbursementType'],
      _expectedReleaseDate = json['expectedReleaseDate'] != null ? amplify_core.TemporalDate.fromString(json['expectedReleaseDate']) : null,
      _initiator = json['initiator'] != null
          ? json['initiator']['serializedData'] != null
              ? UserPreview.fromJson(new Map<String, dynamic>.from(json['initiator']['serializedData']))
              : UserPreview.fromJson(new Map<String, dynamic>.from(json['initiator']))
        : null,
      _sender = json['sender'] != null
          ? json['sender']['serializedData'] != null
              ? UserPreview.fromJson(new Map<String, dynamic>.from(json['sender']['serializedData']))
              : UserPreview.fromJson(new Map<String, dynamic>.from(json['sender']))
        : null,
      _recipient = json['recipient'] != null
          ? json['recipient']['serializedData'] != null
              ? UserPreview.fromJson(new Map<String, dynamic>.from(json['recipient']['serializedData']))
              : UserPreview.fromJson(new Map<String, dynamic>.from(json['recipient']))
        : null,
      _recipientBankName = json['recipientBankName'],
      _recipientAccountName = json['recipientAccountName'],
      _recipientAccountNumber = json['recipientAccountNumber'],
      _milestones = json['milestones'] is List
        ? (json['milestones'] as List)
          .where((e) => e != null)
          .map((e) => MilestonePreview.fromJson(new Map<String, dynamic>.from(e['serializedData'] ?? e)))
          .toList()
        : null;
  
  Map<String, dynamic> toJson() => {
    'shortCode': _shortCode, 'amount': _amount, 'currency': _currency, 'description': _description, 'category': _category, 'status': _status, 'initiatorRole': _initiatorRole, 'disbursementType': _disbursementType, 'expectedReleaseDate': _expectedReleaseDate?.format(), 'initiator': _initiator?.toJson(), 'sender': _sender?.toJson(), 'recipient': _recipient?.toJson(), 'recipientBankName': _recipientBankName, 'recipientAccountName': _recipientAccountName, 'recipientAccountNumber': _recipientAccountNumber, 'milestones': _milestones?.map((MilestonePreview? e) => e?.toJson()).toList()
  };
  
  Map<String, Object?> toMap() => {
    'shortCode': _shortCode,
    'amount': _amount,
    'currency': _currency,
    'description': _description,
    'category': _category,
    'status': _status,
    'initiatorRole': _initiatorRole,
    'disbursementType': _disbursementType,
    'expectedReleaseDate': _expectedReleaseDate,
    'initiator': _initiator,
    'sender': _sender,
    'recipient': _recipient,
    'recipientBankName': _recipientBankName,
    'recipientAccountName': _recipientAccountName,
    'recipientAccountNumber': _recipientAccountNumber,
    'milestones': _milestones
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "AgreementPreview";
    modelSchemaDefinition.pluralName = "AgreementPreviews";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'shortCode',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'amount',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'currency',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'description',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'category',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'status',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'initiatorRole',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'disbursementType',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'expectedReleaseDate',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'initiator',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embedded, ofCustomTypeName: 'UserPreview')
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'sender',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embedded, ofCustomTypeName: 'UserPreview')
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'recipient',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embedded, ofCustomTypeName: 'UserPreview')
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'recipientBankName',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'recipientAccountName',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'recipientAccountNumber',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'milestones',
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embeddedCollection, ofCustomTypeName: 'MilestonePreview')
    ));
  });
}