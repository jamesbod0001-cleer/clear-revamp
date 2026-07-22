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


/** This is an auto generated class representing the PayoutDestination type in your schema. */
class PayoutDestination extends amplify_core.Model {
  static const classType = const _PayoutDestinationModelType();
  final String? _accountNumber;
  final String? _bankCode;
  final String? _currency;
  final String? _bankName;
  final String? _accountName;
  final User? _user;
  final List<Agreement>? _agreements;
  final List<Payout>? _payouts;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => modelIdentifier.serializeAsString();
  
  PayoutDestinationModelIdentifier get modelIdentifier {
    try {
      return PayoutDestinationModelIdentifier(
        accountNumber: _accountNumber!,
        bankCode: _bankCode!
      );
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get accountNumber {
    try {
      return _accountNumber!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get bankCode {
    try {
      return _bankCode!;
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
  
  String get bankName {
    try {
      return _bankName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get accountName {
    try {
      return _accountName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  User? get user {
    return _user;
  }
  
  List<Agreement>? get agreements {
    return _agreements;
  }
  
  List<Payout>? get payouts {
    return _payouts;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const PayoutDestination._internal({required accountNumber, required bankCode, required currency, required bankName, required accountName, user, agreements, payouts, createdAt, updatedAt}): _accountNumber = accountNumber, _bankCode = bankCode, _currency = currency, _bankName = bankName, _accountName = accountName, _user = user, _agreements = agreements, _payouts = payouts, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory PayoutDestination({required String accountNumber, required String bankCode, required String currency, required String bankName, required String accountName, User? user, List<Agreement>? agreements, List<Payout>? payouts}) {
    return PayoutDestination._internal(
      accountNumber: accountNumber,
      bankCode: bankCode,
      currency: currency,
      bankName: bankName,
      accountName: accountName,
      user: user,
      agreements: agreements != null ? List<Agreement>.unmodifiable(agreements) : agreements,
      payouts: payouts != null ? List<Payout>.unmodifiable(payouts) : payouts);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PayoutDestination &&
      _accountNumber == other._accountNumber &&
      _bankCode == other._bankCode &&
      _currency == other._currency &&
      _bankName == other._bankName &&
      _accountName == other._accountName &&
      _user == other._user &&
      DeepCollectionEquality().equals(_agreements, other._agreements) &&
      DeepCollectionEquality().equals(_payouts, other._payouts);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("PayoutDestination {");
    buffer.write("accountNumber=" + "$_accountNumber" + ", ");
    buffer.write("bankCode=" + "$_bankCode" + ", ");
    buffer.write("currency=" + "$_currency" + ", ");
    buffer.write("bankName=" + "$_bankName" + ", ");
    buffer.write("accountName=" + "$_accountName" + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  PayoutDestination copyWith({String? currency, String? bankName, String? accountName, User? user, List<Agreement>? agreements, List<Payout>? payouts}) {
    return PayoutDestination._internal(
      accountNumber: accountNumber,
      bankCode: bankCode,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      user: user ?? this.user,
      agreements: agreements ?? this.agreements,
      payouts: payouts ?? this.payouts);
  }
  
  PayoutDestination copyWithModelFieldValues({
    ModelFieldValue<String>? currency,
    ModelFieldValue<String>? bankName,
    ModelFieldValue<String>? accountName,
    ModelFieldValue<User?>? user,
    ModelFieldValue<List<Agreement>?>? agreements,
    ModelFieldValue<List<Payout>?>? payouts
  }) {
    return PayoutDestination._internal(
      accountNumber: accountNumber,
      bankCode: bankCode,
      currency: currency == null ? this.currency : currency.value,
      bankName: bankName == null ? this.bankName : bankName.value,
      accountName: accountName == null ? this.accountName : accountName.value,
      user: user == null ? this.user : user.value,
      agreements: agreements == null ? this.agreements : agreements.value,
      payouts: payouts == null ? this.payouts : payouts.value
    );
  }
  
  PayoutDestination.fromJson(Map<String, dynamic> json)  
    : _accountNumber = json['accountNumber'],
      _bankCode = json['bankCode'],
      _currency = json['currency'],
      _bankName = json['bankName'],
      _accountName = json['accountName'],
      _user = json['user'] != null
        ? json['user']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['user']))
        : null,
      _agreements = json['agreements']  is Map
        ? (json['agreements']['items'] is List
          ? (json['agreements']['items'] as List)
              .where((e) => e != null)
              .map((e) => Agreement.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['agreements'] is List
          ? (json['agreements'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => Agreement.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _payouts = json['payouts']  is Map
        ? (json['payouts']['items'] is List
          ? (json['payouts']['items'] as List)
              .where((e) => e != null)
              .map((e) => Payout.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['payouts'] is List
          ? (json['payouts'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => Payout.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'accountNumber': _accountNumber, 'bankCode': _bankCode, 'currency': _currency, 'bankName': _bankName, 'accountName': _accountName, 'user': _user?.toJson(), 'agreements': _agreements?.map((Agreement? e) => e?.toJson()).toList(), 'payouts': _payouts?.map((Payout? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'accountNumber': _accountNumber,
    'bankCode': _bankCode,
    'currency': _currency,
    'bankName': _bankName,
    'accountName': _accountName,
    'user': _user,
    'agreements': _agreements,
    'payouts': _payouts,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PayoutDestinationModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PayoutDestinationModelIdentifier>();
  static final ACCOUNTNUMBER = amplify_core.QueryField(fieldName: "accountNumber");
  static final BANKCODE = amplify_core.QueryField(fieldName: "bankCode");
  static final CURRENCY = amplify_core.QueryField(fieldName: "currency");
  static final BANKNAME = amplify_core.QueryField(fieldName: "bankName");
  static final ACCOUNTNAME = amplify_core.QueryField(fieldName: "accountName");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final AGREEMENTS = amplify_core.QueryField(
    fieldName: "agreements",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Agreement'));
  static final PAYOUTS = amplify_core.QueryField(
    fieldName: "payouts",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Payout'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PayoutDestination";
    modelSchemaDefinition.pluralName = "PayoutDestinations";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["accountNumber", "bankCode"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PayoutDestination.ACCOUNTNUMBER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PayoutDestination.BANKCODE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PayoutDestination.CURRENCY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PayoutDestination.BANKNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PayoutDestination.ACCOUNTNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: PayoutDestination.USER,
      isRequired: false,
      targetNames: ['userId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: PayoutDestination.AGREEMENTS,
      isRequired: false,
      ofModelName: 'Agreement',
      associatedKey: Agreement.PAYOUTDESTINATION
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: PayoutDestination.PAYOUTS,
      isRequired: false,
      ofModelName: 'Payout',
      associatedKey: Payout.PAYOUTDESTINATION
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

class _PayoutDestinationModelType extends amplify_core.ModelType<PayoutDestination> {
  const _PayoutDestinationModelType();
  
  @override
  PayoutDestination fromJson(Map<String, dynamic> jsonData) {
    return PayoutDestination.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'PayoutDestination';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [PayoutDestination] in your schema.
 */
class PayoutDestinationModelIdentifier implements amplify_core.ModelIdentifier<PayoutDestination> {
  final String accountNumber;
  final String bankCode;

  /**
   * Create an instance of PayoutDestinationModelIdentifier using [accountNumber] the primary key.
   * And [bankCode] the sort key.
   */
  const PayoutDestinationModelIdentifier({
    required this.accountNumber,
    required this.bankCode});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'accountNumber': accountNumber,
    'bankCode': bankCode
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'PayoutDestinationModelIdentifier(accountNumber: $accountNumber, bankCode: $bankCode)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PayoutDestinationModelIdentifier &&
      accountNumber == other.accountNumber &&
      bankCode == other.bankCode;
  }
  
  @override
  int get hashCode =>
    accountNumber.hashCode ^
    bankCode.hashCode;
}