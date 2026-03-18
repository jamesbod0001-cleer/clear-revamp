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


/** This is an auto generated class representing the StatusHistory type in your schema. */
class StatusHistory extends amplify_core.Model {
  static const classType = const _StatusHistoryModelType();
  final String id;
  final String? _oldStatus;
  final String? _newStatus;
  final String? _changedBy;
  final Agreement? _agreement;
  final Milestone? _milestone;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  StatusHistoryModelIdentifier get modelIdentifier {
      return StatusHistoryModelIdentifier(
        id: id
      );
  }
  
  String? get oldStatus {
    return _oldStatus;
  }
  
  String get newStatus {
    try {
      return _newStatus!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get changedBy {
    return _changedBy;
  }
  
  Agreement? get agreement {
    return _agreement;
  }
  
  Milestone? get milestone {
    return _milestone;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const StatusHistory._internal({required this.id, oldStatus, required newStatus, changedBy, agreement, milestone, createdAt, updatedAt}): _oldStatus = oldStatus, _newStatus = newStatus, _changedBy = changedBy, _agreement = agreement, _milestone = milestone, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory StatusHistory({String? id, String? oldStatus, required String newStatus, String? changedBy, Agreement? agreement, Milestone? milestone}) {
    return StatusHistory._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedBy: changedBy,
      agreement: agreement,
      milestone: milestone);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StatusHistory &&
      id == other.id &&
      _oldStatus == other._oldStatus &&
      _newStatus == other._newStatus &&
      _changedBy == other._changedBy &&
      _agreement == other._agreement &&
      _milestone == other._milestone;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("StatusHistory {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("oldStatus=" + "$_oldStatus" + ", ");
    buffer.write("newStatus=" + "$_newStatus" + ", ");
    buffer.write("changedBy=" + "$_changedBy" + ", ");
    buffer.write("agreement=" + (_agreement != null ? _agreement!.toString() : "null") + ", ");
    buffer.write("milestone=" + (_milestone != null ? _milestone!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  StatusHistory copyWith({String? oldStatus, String? newStatus, String? changedBy, Agreement? agreement, Milestone? milestone}) {
    return StatusHistory._internal(
      id: id,
      oldStatus: oldStatus ?? this.oldStatus,
      newStatus: newStatus ?? this.newStatus,
      changedBy: changedBy ?? this.changedBy,
      agreement: agreement ?? this.agreement,
      milestone: milestone ?? this.milestone);
  }
  
  StatusHistory copyWithModelFieldValues({
    ModelFieldValue<String?>? oldStatus,
    ModelFieldValue<String>? newStatus,
    ModelFieldValue<String?>? changedBy,
    ModelFieldValue<Agreement?>? agreement,
    ModelFieldValue<Milestone?>? milestone
  }) {
    return StatusHistory._internal(
      id: id,
      oldStatus: oldStatus == null ? this.oldStatus : oldStatus.value,
      newStatus: newStatus == null ? this.newStatus : newStatus.value,
      changedBy: changedBy == null ? this.changedBy : changedBy.value,
      agreement: agreement == null ? this.agreement : agreement.value,
      milestone: milestone == null ? this.milestone : milestone.value
    );
  }
  
  StatusHistory.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _oldStatus = json['oldStatus'],
      _newStatus = json['newStatus'],
      _changedBy = json['changedBy'],
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
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'oldStatus': _oldStatus, 'newStatus': _newStatus, 'changedBy': _changedBy, 'agreement': _agreement?.toJson(), 'milestone': _milestone?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'oldStatus': _oldStatus,
    'newStatus': _newStatus,
    'changedBy': _changedBy,
    'agreement': _agreement,
    'milestone': _milestone,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<StatusHistoryModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<StatusHistoryModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final OLDSTATUS = amplify_core.QueryField(fieldName: "oldStatus");
  static final NEWSTATUS = amplify_core.QueryField(fieldName: "newStatus");
  static final CHANGEDBY = amplify_core.QueryField(fieldName: "changedBy");
  static final AGREEMENT = amplify_core.QueryField(
    fieldName: "agreement",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Agreement'));
  static final MILESTONE = amplify_core.QueryField(
    fieldName: "milestone",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Milestone'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "StatusHistory";
    modelSchemaDefinition.pluralName = "StatusHistories";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: StatusHistory.OLDSTATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: StatusHistory.NEWSTATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: StatusHistory.CHANGEDBY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: StatusHistory.AGREEMENT,
      isRequired: false,
      targetNames: ['agreementId'],
      ofModelName: 'Agreement'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: StatusHistory.MILESTONE,
      isRequired: false,
      targetNames: ['milestoneId'],
      ofModelName: 'Milestone'
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

class _StatusHistoryModelType extends amplify_core.ModelType<StatusHistory> {
  const _StatusHistoryModelType();
  
  @override
  StatusHistory fromJson(Map<String, dynamic> jsonData) {
    return StatusHistory.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'StatusHistory';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [StatusHistory] in your schema.
 */
class StatusHistoryModelIdentifier implements amplify_core.ModelIdentifier<StatusHistory> {
  final String id;

  /** Create an instance of StatusHistoryModelIdentifier using [id] the primary key. */
  const StatusHistoryModelIdentifier({
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
  String toString() => 'StatusHistoryModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is StatusHistoryModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}