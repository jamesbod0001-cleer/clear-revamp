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


/** This is an auto generated class representing the Activity type in your schema. */
class Activity extends amplify_core.Model {
  static const classType = const _ActivityModelType();
  final String id;
  final String? _userId;
  final ActivityType? _type;
  final String? _heading;
  final String? _supportingText;
  final String? _formattedAmount;
  final String? _description;
  final bool? _isRead;
  final String? _entityId;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ActivityModelIdentifier get modelIdentifier {
      return ActivityModelIdentifier(
        id: id
      );
  }
  
  String get userId {
    try {
      return _userId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  ActivityType? get type {
    return _type;
  }
  
  String get heading {
    try {
      return _heading!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get supportingText {
    try {
      return _supportingText!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get formattedAmount {
    return _formattedAmount;
  }
  
  String? get description {
    return _description;
  }
  
  bool? get isRead {
    return _isRead;
  }
  
  String? get entityId {
    return _entityId;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Activity._internal({required this.id, required userId, type, required heading, required supportingText, formattedAmount, description, isRead, entityId, createdAt, updatedAt}): _userId = userId, _type = type, _heading = heading, _supportingText = supportingText, _formattedAmount = formattedAmount, _description = description, _isRead = isRead, _entityId = entityId, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Activity({String? id, required String userId, ActivityType? type, required String heading, required String supportingText, String? formattedAmount, String? description, bool? isRead, String? entityId, amplify_core.TemporalDateTime? createdAt}) {
    return Activity._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      type: type,
      heading: heading,
      supportingText: supportingText,
      formattedAmount: formattedAmount,
      description: description,
      isRead: isRead,
      entityId: entityId,
      createdAt: createdAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Activity &&
      id == other.id &&
      _userId == other._userId &&
      _type == other._type &&
      _heading == other._heading &&
      _supportingText == other._supportingText &&
      _formattedAmount == other._formattedAmount &&
      _description == other._description &&
      _isRead == other._isRead &&
      _entityId == other._entityId &&
      _createdAt == other._createdAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Activity {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("type=" + (_type != null ? amplify_core.enumToString(_type)! : "null") + ", ");
    buffer.write("heading=" + "$_heading" + ", ");
    buffer.write("supportingText=" + "$_supportingText" + ", ");
    buffer.write("formattedAmount=" + "$_formattedAmount" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("isRead=" + (_isRead != null ? _isRead!.toString() : "null") + ", ");
    buffer.write("entityId=" + "$_entityId" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Activity copyWith({String? userId, ActivityType? type, String? heading, String? supportingText, String? formattedAmount, String? description, bool? isRead, String? entityId, amplify_core.TemporalDateTime? createdAt}) {
    return Activity._internal(
      id: id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      heading: heading ?? this.heading,
      supportingText: supportingText ?? this.supportingText,
      formattedAmount: formattedAmount ?? this.formattedAmount,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
      entityId: entityId ?? this.entityId,
      createdAt: createdAt ?? this.createdAt);
  }
  
  Activity copyWithModelFieldValues({
    ModelFieldValue<String>? userId,
    ModelFieldValue<ActivityType?>? type,
    ModelFieldValue<String>? heading,
    ModelFieldValue<String>? supportingText,
    ModelFieldValue<String?>? formattedAmount,
    ModelFieldValue<String?>? description,
    ModelFieldValue<bool?>? isRead,
    ModelFieldValue<String?>? entityId,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt
  }) {
    return Activity._internal(
      id: id,
      userId: userId == null ? this.userId : userId.value,
      type: type == null ? this.type : type.value,
      heading: heading == null ? this.heading : heading.value,
      supportingText: supportingText == null ? this.supportingText : supportingText.value,
      formattedAmount: formattedAmount == null ? this.formattedAmount : formattedAmount.value,
      description: description == null ? this.description : description.value,
      isRead: isRead == null ? this.isRead : isRead.value,
      entityId: entityId == null ? this.entityId : entityId.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value
    );
  }
  
  Activity.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _type = amplify_core.enumFromString<ActivityType>(json['type'], ActivityType.values),
      _heading = json['heading'],
      _supportingText = json['supportingText'],
      _formattedAmount = json['formattedAmount'],
      _description = json['description'],
      _isRead = json['isRead'],
      _entityId = json['entityId'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'type': amplify_core.enumToString(_type), 'heading': _heading, 'supportingText': _supportingText, 'formattedAmount': _formattedAmount, 'description': _description, 'isRead': _isRead, 'entityId': _entityId, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'type': _type,
    'heading': _heading,
    'supportingText': _supportingText,
    'formattedAmount': _formattedAmount,
    'description': _description,
    'isRead': _isRead,
    'entityId': _entityId,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ActivityModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ActivityModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final TYPE = amplify_core.QueryField(fieldName: "type");
  static final HEADING = amplify_core.QueryField(fieldName: "heading");
  static final SUPPORTINGTEXT = amplify_core.QueryField(fieldName: "supportingText");
  static final FORMATTEDAMOUNT = amplify_core.QueryField(fieldName: "formattedAmount");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final ISREAD = amplify_core.QueryField(fieldName: "isRead");
  static final ENTITYID = amplify_core.QueryField(fieldName: "entityId");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Activity";
    modelSchemaDefinition.pluralName = "Activities";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "userId",
        identityClaim: "sub",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["userId", "createdAt"], name: "activitiesByUserIdAndCreatedAt")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.HEADING,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.SUPPORTINGTEXT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.FORMATTEDAMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.ISREAD,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.ENTITYID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Activity.CREATEDAT,
      isRequired: false,
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

class _ActivityModelType extends amplify_core.ModelType<Activity> {
  const _ActivityModelType();
  
  @override
  Activity fromJson(Map<String, dynamic> jsonData) {
    return Activity.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Activity';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Activity] in your schema.
 */
class ActivityModelIdentifier implements amplify_core.ModelIdentifier<Activity> {
  final String id;

  /** Create an instance of ActivityModelIdentifier using [id] the primary key. */
  const ActivityModelIdentifier({
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
  String toString() => 'ActivityModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ActivityModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}