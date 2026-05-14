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

/** This is an auto generated class representing the User type in your schema. */
class User extends amplify_core.Model {
  static const classType = const _UserModelType();
  final String id;
  final String? _identityId;
  final String? _phoneNumber;
  final String? _firstName;
  final String? _lastName;
  final String? _email;
  final bool? _isEmailVerified;
  final Photo? _profilePicture;
  final String? _flutterwaveCustomerId;
  final List<String>? _flutterwavePaymentMethodIds;
  final List<Agreement>? _initiatedAgreements;
  final List<Agreement>? _sentAgreements;
  final List<Agreement>? _receivedAgreements;
  final List<PayoutDestination>? _payoutDestinations;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  UserModelIdentifier get modelIdentifier {
    return UserModelIdentifier(id: id);
  }

  String get identityId {
    try {
      return _identityId!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString(),
      );
    }
  }

  String get phoneNumber {
    try {
      return _phoneNumber!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString(),
      );
    }
  }

  String get firstName {
    try {
      return _firstName!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString(),
      );
    }
  }

  String get lastName {
    try {
      return _lastName!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString(),
      );
    }
  }

  String? get email {
    return _email;
  }

  bool? get isEmailVerified {
    return _isEmailVerified;
  }

  Photo? get profilePicture {
    return _profilePicture;
  }

  String get flutterwaveCustomerId {
    try {
      return _flutterwaveCustomerId!;
    } catch (e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core
            .AmplifyExceptionMessages
            .codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString(),
      );
    }
  }

  List<String>? get flutterwavePaymentMethodIds {
    return _flutterwavePaymentMethodIds;
  }

  List<Agreement>? get initiatedAgreements {
    return _initiatedAgreements;
  }

  List<Agreement>? get sentAgreements {
    return _sentAgreements;
  }

  List<Agreement>? get receivedAgreements {
    return _receivedAgreements;
  }

  List<PayoutDestination>? get payoutDestinations {
    return _payoutDestinations;
  }

  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }

  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const User._internal({
    required this.id,
    required identityId,
    required phoneNumber,
    required firstName,
    required lastName,
    email,
    isEmailVerified,
    profilePicture,
    required flutterwaveCustomerId,
    flutterwavePaymentMethodIds,
    initiatedAgreements,
    sentAgreements,
    receivedAgreements,
    payoutDestinations,
    createdAt,
    updatedAt,
  }) : _identityId = identityId,
       _phoneNumber = phoneNumber,
       _firstName = firstName,
       _lastName = lastName,
       _email = email,
       _isEmailVerified = isEmailVerified,
       _profilePicture = profilePicture,
       _flutterwaveCustomerId = flutterwaveCustomerId,
       _flutterwavePaymentMethodIds = flutterwavePaymentMethodIds,
       _initiatedAgreements = initiatedAgreements,
       _sentAgreements = sentAgreements,
       _receivedAgreements = receivedAgreements,
       _payoutDestinations = payoutDestinations,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory User({
    String? id,
    required String identityId,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? email,
    bool? isEmailVerified,
    Photo? profilePicture,
    required String flutterwaveCustomerId,
    List<String>? flutterwavePaymentMethodIds,
    List<Agreement>? initiatedAgreements,
    List<Agreement>? sentAgreements,
    List<Agreement>? receivedAgreements,
    List<PayoutDestination>? payoutDestinations,
  }) {
    return User._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      identityId: identityId,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      isEmailVerified: isEmailVerified,
      profilePicture: profilePicture,
      flutterwaveCustomerId: flutterwaveCustomerId,
      flutterwavePaymentMethodIds: flutterwavePaymentMethodIds != null
          ? List<String>.unmodifiable(flutterwavePaymentMethodIds)
          : flutterwavePaymentMethodIds,
      initiatedAgreements: initiatedAgreements != null
          ? List<Agreement>.unmodifiable(initiatedAgreements)
          : initiatedAgreements,
      sentAgreements: sentAgreements != null
          ? List<Agreement>.unmodifiable(sentAgreements)
          : sentAgreements,
      receivedAgreements: receivedAgreements != null
          ? List<Agreement>.unmodifiable(receivedAgreements)
          : receivedAgreements,
      payoutDestinations: payoutDestinations != null
          ? List<PayoutDestination>.unmodifiable(payoutDestinations)
          : payoutDestinations,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
        id == other.id &&
        _identityId == other._identityId &&
        _phoneNumber == other._phoneNumber &&
        _firstName == other._firstName &&
        _lastName == other._lastName &&
        _email == other._email &&
        _isEmailVerified == other._isEmailVerified &&
        _profilePicture == other._profilePicture &&
        _flutterwaveCustomerId == other._flutterwaveCustomerId &&
        DeepCollectionEquality().equals(
          _flutterwavePaymentMethodIds,
          other._flutterwavePaymentMethodIds,
        ) &&
        DeepCollectionEquality().equals(
          _initiatedAgreements,
          other._initiatedAgreements,
        ) &&
        DeepCollectionEquality().equals(
          _sentAgreements,
          other._sentAgreements,
        ) &&
        DeepCollectionEquality().equals(
          _receivedAgreements,
          other._receivedAgreements,
        ) &&
        DeepCollectionEquality().equals(
          _payoutDestinations,
          other._payoutDestinations,
        );
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("User {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("identityId=" + "$_identityId" + ", ");
    buffer.write("phoneNumber=" + "$_phoneNumber" + ", ");
    buffer.write("firstName=" + "$_firstName" + ", ");
    buffer.write("lastName=" + "$_lastName" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write(
      "isEmailVerified=" +
          (_isEmailVerified != null ? _isEmailVerified.toString() : "null") +
          ", ",
    );
    buffer.write(
      "profilePicture=" +
          (_profilePicture != null ? _profilePicture.toString() : "null") +
          ", ",
    );
    buffer.write("flutterwaveCustomerId=" + "$_flutterwaveCustomerId" + ", ");
    buffer.write(
      "flutterwavePaymentMethodIds=" +
          (_flutterwavePaymentMethodIds != null
              ? _flutterwavePaymentMethodIds.toString()
              : "null") +
          ", ",
    );
    buffer.write(
      "createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ",
    );
    buffer.write(
      "updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"),
    );
    buffer.write("}");

    return buffer.toString();
  }

  User copyWith({
    String? identityId,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    bool? isEmailVerified,
    Photo? profilePicture,
    String? flutterwaveCustomerId,
    List<String>? flutterwavePaymentMethodIds,
    List<Agreement>? initiatedAgreements,
    List<Agreement>? sentAgreements,
    List<Agreement>? receivedAgreements,
    List<PayoutDestination>? payoutDestinations,
  }) {
    return User._internal(
      id: id,
      identityId: identityId ?? this.identityId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      flutterwaveCustomerId:
          flutterwaveCustomerId ?? this.flutterwaveCustomerId,
      flutterwavePaymentMethodIds:
          flutterwavePaymentMethodIds ?? this.flutterwavePaymentMethodIds,
      initiatedAgreements: initiatedAgreements ?? this.initiatedAgreements,
      sentAgreements: sentAgreements ?? this.sentAgreements,
      receivedAgreements: receivedAgreements ?? this.receivedAgreements,
      payoutDestinations: payoutDestinations ?? this.payoutDestinations,
    );
  }

  User copyWithModelFieldValues({
    ModelFieldValue<String>? identityId,
    ModelFieldValue<String>? phoneNumber,
    ModelFieldValue<String>? firstName,
    ModelFieldValue<String>? lastName,
    ModelFieldValue<String?>? email,
    ModelFieldValue<bool?>? isEmailVerified,
    ModelFieldValue<Photo?>? profilePicture,
    ModelFieldValue<String>? flutterwaveCustomerId,
    ModelFieldValue<List<String>?>? flutterwavePaymentMethodIds,
    ModelFieldValue<List<Agreement>?>? initiatedAgreements,
    ModelFieldValue<List<Agreement>?>? sentAgreements,
    ModelFieldValue<List<Agreement>?>? receivedAgreements,
    ModelFieldValue<List<PayoutDestination>?>? payoutDestinations,
  }) {
    return User._internal(
      id: id,
      identityId: identityId == null ? this.identityId : identityId.value,
      phoneNumber: phoneNumber == null ? this.phoneNumber : phoneNumber.value,
      firstName: firstName == null ? this.firstName : firstName.value,
      lastName: lastName == null ? this.lastName : lastName.value,
      email: email == null ? this.email : email.value,
      isEmailVerified: isEmailVerified == null
          ? this.isEmailVerified
          : isEmailVerified.value,
      profilePicture: profilePicture == null
          ? this.profilePicture
          : profilePicture.value,
      flutterwaveCustomerId: flutterwaveCustomerId == null
          ? this.flutterwaveCustomerId
          : flutterwaveCustomerId.value,
      flutterwavePaymentMethodIds: flutterwavePaymentMethodIds == null
          ? this.flutterwavePaymentMethodIds
          : flutterwavePaymentMethodIds.value,
      initiatedAgreements: initiatedAgreements == null
          ? this.initiatedAgreements
          : initiatedAgreements.value,
      sentAgreements: sentAgreements == null
          ? this.sentAgreements
          : sentAgreements.value,
      receivedAgreements: receivedAgreements == null
          ? this.receivedAgreements
          : receivedAgreements.value,
      payoutDestinations: payoutDestinations == null
          ? this.payoutDestinations
          : payoutDestinations.value,
    );
  }

  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _identityId = json['identityId'],
      _phoneNumber = json['phoneNumber'],
      _firstName = json['firstName'],
      _lastName = json['lastName'],
      _email = json['email'],
      _isEmailVerified = json['isEmailVerified'],
      _profilePicture = json['profilePicture'] != null
          ? json['profilePicture']['serializedData'] != null
                ? Photo.fromJson(
                    new Map<String, dynamic>.from(
                      json['profilePicture']['serializedData'],
                    ),
                  )
                : Photo.fromJson(
                    new Map<String, dynamic>.from(json['profilePicture']),
                  )
          : null,
      _flutterwaveCustomerId = json['flutterwaveCustomerId'],
      _flutterwavePaymentMethodIds = json['flutterwavePaymentMethodIds']
          ?.cast<String>(),
      _initiatedAgreements = json['initiatedAgreements'] is Map
          ? (json['initiatedAgreements']['items'] is List
                ? (json['initiatedAgreements']['items'] as List)
                      .where((e) => e != null)
                      .map(
                        (e) => Agreement.fromJson(
                          new Map<String, dynamic>.from(e),
                        ),
                      )
                      .toList()
                : null)
          : (json['initiatedAgreements'] is List
                ? (json['initiatedAgreements'] as List)
                      .where((e) => e?['serializedData'] != null)
                      .map(
                        (e) => Agreement.fromJson(
                          new Map<String, dynamic>.from(e?['serializedData']),
                        ),
                      )
                      .toList()
                : null),
      _sentAgreements = json['sentAgreements'] is Map
          ? (json['sentAgreements']['items'] is List
                ? (json['sentAgreements']['items'] as List)
                      .where((e) => e != null)
                      .map(
                        (e) => Agreement.fromJson(
                          new Map<String, dynamic>.from(e),
                        ),
                      )
                      .toList()
                : null)
          : (json['sentAgreements'] is List
                ? (json['sentAgreements'] as List)
                      .where((e) => e?['serializedData'] != null)
                      .map(
                        (e) => Agreement.fromJson(
                          new Map<String, dynamic>.from(e?['serializedData']),
                        ),
                      )
                      .toList()
                : null),
      _receivedAgreements = json['receivedAgreements'] is Map
          ? (json['receivedAgreements']['items'] is List
                ? (json['receivedAgreements']['items'] as List)
                      .where((e) => e != null)
                      .map(
                        (e) => Agreement.fromJson(
                          new Map<String, dynamic>.from(e),
                        ),
                      )
                      .toList()
                : null)
          : (json['receivedAgreements'] is List
                ? (json['receivedAgreements'] as List)
                      .where((e) => e?['serializedData'] != null)
                      .map(
                        (e) => Agreement.fromJson(
                          new Map<String, dynamic>.from(e?['serializedData']),
                        ),
                      )
                      .toList()
                : null),
      _payoutDestinations = json['payoutDestinations'] is Map
          ? (json['payoutDestinations']['items'] is List
                ? (json['payoutDestinations']['items'] as List)
                      .where((e) => e != null)
                      .map(
                        (e) => PayoutDestination.fromJson(
                          new Map<String, dynamic>.from(e),
                        ),
                      )
                      .toList()
                : null)
          : (json['payoutDestinations'] is List
                ? (json['payoutDestinations'] as List)
                      .where((e) => e?['serializedData'] != null)
                      .map(
                        (e) => PayoutDestination.fromJson(
                          new Map<String, dynamic>.from(e?['serializedData']),
                        ),
                      )
                      .toList()
                : null),
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'identityId': _identityId,
    'phoneNumber': _phoneNumber,
    'firstName': _firstName,
    'lastName': _lastName,
    'email': _email,
    'isEmailVerified': _isEmailVerified,
    'profilePicture': _profilePicture?.toJson(),
    'flutterwaveCustomerId': _flutterwaveCustomerId,
    'flutterwavePaymentMethodIds': _flutterwavePaymentMethodIds,
    'initiatedAgreements': _initiatedAgreements
        ?.map((Agreement? e) => e?.toJson())
        .toList(),
    'sentAgreements': _sentAgreements
        ?.map((Agreement? e) => e?.toJson())
        .toList(),
    'receivedAgreements': _receivedAgreements
        ?.map((Agreement? e) => e?.toJson())
        .toList(),
    'payoutDestinations': _payoutDestinations
        ?.map((PayoutDestination? e) => e?.toJson())
        .toList(),
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'identityId': _identityId,
    'phoneNumber': _phoneNumber,
    'firstName': _firstName,
    'lastName': _lastName,
    'email': _email,
    'isEmailVerified': _isEmailVerified,
    'profilePicture': _profilePicture,
    'flutterwaveCustomerId': _flutterwaveCustomerId,
    'flutterwavePaymentMethodIds': _flutterwavePaymentMethodIds,
    'initiatedAgreements': _initiatedAgreements,
    'sentAgreements': _sentAgreements,
    'receivedAgreements': _receivedAgreements,
    'payoutDestinations': _payoutDestinations,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<UserModelIdentifier>
  MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final IDENTITYID = amplify_core.QueryField(fieldName: "identityId");
  static final PHONENUMBER = amplify_core.QueryField(fieldName: "phoneNumber");
  static final FIRSTNAME = amplify_core.QueryField(fieldName: "firstName");
  static final LASTNAME = amplify_core.QueryField(fieldName: "lastName");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final ISEMAILVERIFIED = amplify_core.QueryField(
    fieldName: "isEmailVerified",
  );
  static final PROFILEPICTURE = amplify_core.QueryField(
    fieldName: "profilePicture",
  );
  static final FLUTTERWAVECUSTOMERID = amplify_core.QueryField(
    fieldName: "flutterwaveCustomerId",
  );
  static final FLUTTERWAVEPAYMENTMETHODIDS = amplify_core.QueryField(
    fieldName: "flutterwavePaymentMethodIds",
  );
  static final INITIATEDAGREEMENTS = amplify_core.QueryField(
    fieldName: "initiatedAgreements",
    fieldType: amplify_core.ModelFieldType(
      amplify_core.ModelFieldTypeEnum.model,
      ofModelName: 'Agreement',
    ),
  );
  static final SENTAGREEMENTS = amplify_core.QueryField(
    fieldName: "sentAgreements",
    fieldType: amplify_core.ModelFieldType(
      amplify_core.ModelFieldTypeEnum.model,
      ofModelName: 'Agreement',
    ),
  );
  static final RECEIVEDAGREEMENTS = amplify_core.QueryField(
    fieldName: "receivedAgreements",
    fieldType: amplify_core.ModelFieldType(
      amplify_core.ModelFieldTypeEnum.model,
      ofModelName: 'Agreement',
    ),
  );
  static final PAYOUTDESTINATIONS = amplify_core.QueryField(
    fieldName: "payoutDestinations",
    fieldType: amplify_core.ModelFieldType(
      amplify_core.ModelFieldTypeEnum.model,
      ofModelName: 'PayoutDestination',
    ),
  );
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "User";
      modelSchemaDefinition.pluralName = "Users";

      modelSchemaDefinition.authRules = [
        amplify_core.AuthRule(
          authStrategy: amplify_core.AuthStrategy.OWNER,
          ownerField: "id",
          identityClaim: "sub",
          provider: amplify_core.AuthRuleProvider.USERPOOLS,
          operations: const [
            amplify_core.ModelOperation.CREATE,
            amplify_core.ModelOperation.UPDATE,
            amplify_core.ModelOperation.DELETE,
            amplify_core.ModelOperation.READ,
          ],
        ),
      ];

      modelSchemaDefinition.indexes = [
        amplify_core.ModelIndex(fields: const ["id"], name: null),
      ];

      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.IDENTITYID,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.PHONENUMBER,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.FIRSTNAME,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.LASTNAME,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.EMAIL,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.ISEMAILVERIFIED,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.bool,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.embedded(
          fieldName: 'profilePicture',
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.embedded,
            ofCustomTypeName: 'Photo',
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.FLUTTERWAVECUSTOMERID,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: User.FLUTTERWAVEPAYMENTMETHODIDS,
          isRequired: false,
          isArray: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.collection,
            ofModelName: amplify_core.ModelFieldTypeEnum.string.name,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.hasMany(
          key: User.INITIATEDAGREEMENTS,
          isRequired: false,
          ofModelName: 'Agreement',
          associatedKey: Agreement.INITIATOR,
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.hasMany(
          key: User.SENTAGREEMENTS,
          isRequired: false,
          ofModelName: 'Agreement',
          associatedKey: Agreement.SENDER,
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.hasMany(
          key: User.RECEIVEDAGREEMENTS,
          isRequired: false,
          ofModelName: 'Agreement',
          associatedKey: Agreement.RECIPIENT,
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.hasMany(
          key: User.PAYOUTDESTINATIONS,
          isRequired: false,
          ofModelName: 'PayoutDestination',
          associatedKey: PayoutDestination.USER,
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'createdAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.dateTime,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'updatedAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.dateTime,
          ),
        ),
      );
    },
  );
}

class _UserModelType extends amplify_core.ModelType<User> {
  const _UserModelType();

  @override
  User fromJson(Map<String, dynamic> jsonData) {
    return User.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'User';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [User] in your schema.
 */
class UserModelIdentifier implements amplify_core.ModelIdentifier<User> {
  final String id;

  /** Create an instance of UserModelIdentifier using [id] the primary key. */
  const UserModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'UserModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UserModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
