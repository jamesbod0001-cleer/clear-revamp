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


/** This is an auto generated class representing the Dispute type in your schema. */
class Dispute extends amplify_core.Model {
  static const classType = const _DisputeModelType();
  final String id;
  final String? _reason;
  final String? _description;
  final List<String>? _evidenceKeys;
  final DisputeStatus? _status;
  final List<String>? _participants;
  final String? _lastUpdatedBy;
  final Agreement? _agreement;
  final Milestone? _milestone;
  final User? _raisedBy;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DisputeModelIdentifier get modelIdentifier {
      return DisputeModelIdentifier(
        id: id
      );
  }
  
  String get reason {
    try {
      return _reason!;
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
  
  List<String>? get evidenceKeys {
    return _evidenceKeys;
  }
  
  DisputeStatus? get status {
    return _status;
  }
  
  List<String>? get participants {
    return _participants;
  }
  
  String? get lastUpdatedBy {
    return _lastUpdatedBy;
  }
  
  Agreement? get agreement {
    return _agreement;
  }
  
  Milestone? get milestone {
    return _milestone;
  }
  
  User? get raisedBy {
    return _raisedBy;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Dispute._internal({required this.id, required reason, required description, evidenceKeys, status, participants, lastUpdatedBy, agreement, milestone, raisedBy, createdAt, updatedAt}): _reason = reason, _description = description, _evidenceKeys = evidenceKeys, _status = status, _participants = participants, _lastUpdatedBy = lastUpdatedBy, _agreement = agreement, _milestone = milestone, _raisedBy = raisedBy, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Dispute({String? id, required String reason, required String description, List<String>? evidenceKeys, DisputeStatus? status, List<String>? participants, String? lastUpdatedBy, Agreement? agreement, Milestone? milestone, User? raisedBy, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Dispute._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      reason: reason,
      description: description,
      evidenceKeys: evidenceKeys != null ? List<String>.unmodifiable(evidenceKeys) : evidenceKeys,
      status: status,
      participants: participants != null ? List<String>.unmodifiable(participants) : participants,
      lastUpdatedBy: lastUpdatedBy,
      agreement: agreement,
      milestone: milestone,
      raisedBy: raisedBy,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Dispute &&
      id == other.id &&
      _reason == other._reason &&
      _description == other._description &&
      DeepCollectionEquality().equals(_evidenceKeys, other._evidenceKeys) &&
      _status == other._status &&
      DeepCollectionEquality().equals(_participants, other._participants) &&
      _lastUpdatedBy == other._lastUpdatedBy &&
      _agreement == other._agreement &&
      _milestone == other._milestone &&
      _raisedBy == other._raisedBy &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Dispute {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("reason=" + "$_reason" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("evidenceKeys=" + (_evidenceKeys != null ? _evidenceKeys!.toString() : "null") + ", ");
    buffer.write("status=" + (_status != null ? amplify_core.enumToString(_status)! : "null") + ", ");
    buffer.write("participants=" + (_participants != null ? _participants!.toString() : "null") + ", ");
    buffer.write("lastUpdatedBy=" + "$_lastUpdatedBy" + ", ");
    buffer.write("agreement=" + (_agreement != null ? _agreement!.toString() : "null") + ", ");
    buffer.write("milestone=" + (_milestone != null ? _milestone!.toString() : "null") + ", ");
    buffer.write("raisedBy=" + (_raisedBy != null ? _raisedBy!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Dispute copyWith({String? reason, String? description, List<String>? evidenceKeys, DisputeStatus? status, List<String>? participants, String? lastUpdatedBy, Agreement? agreement, Milestone? milestone, User? raisedBy, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Dispute._internal(
      id: id,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      evidenceKeys: evidenceKeys ?? this.evidenceKeys,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      agreement: agreement ?? this.agreement,
      milestone: milestone ?? this.milestone,
      raisedBy: raisedBy ?? this.raisedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Dispute copyWithModelFieldValues({
    ModelFieldValue<String>? reason,
    ModelFieldValue<String>? description,
    ModelFieldValue<List<String>?>? evidenceKeys,
    ModelFieldValue<DisputeStatus?>? status,
    ModelFieldValue<List<String>?>? participants,
    ModelFieldValue<String?>? lastUpdatedBy,
    ModelFieldValue<Agreement?>? agreement,
    ModelFieldValue<Milestone?>? milestone,
    ModelFieldValue<User?>? raisedBy,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime?>? updatedAt
  }) {
    return Dispute._internal(
      id: id,
      reason: reason == null ? this.reason : reason.value,
      description: description == null ? this.description : description.value,
      evidenceKeys: evidenceKeys == null ? this.evidenceKeys : evidenceKeys.value,
      status: status == null ? this.status : status.value,
      participants: participants == null ? this.participants : participants.value,
      lastUpdatedBy: lastUpdatedBy == null ? this.lastUpdatedBy : lastUpdatedBy.value,
      agreement: agreement == null ? this.agreement : agreement.value,
      milestone: milestone == null ? this.milestone : milestone.value,
      raisedBy: raisedBy == null ? this.raisedBy : raisedBy.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Dispute.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _reason = json['reason'],
      _description = json['description'],
      _evidenceKeys = json['evidenceKeys']?.cast<String>(),
      _status = amplify_core.enumFromString<DisputeStatus>(json['status'], DisputeStatus.values),
      _participants = json['participants']?.cast<String>(),
      _lastUpdatedBy = json['lastUpdatedBy'],
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
      _raisedBy = json['raisedBy'] != null
        ? json['raisedBy']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['raisedBy']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['raisedBy']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'reason': _reason, 'description': _description, 'evidenceKeys': _evidenceKeys, 'status': amplify_core.enumToString(_status), 'participants': _participants, 'lastUpdatedBy': _lastUpdatedBy, 'agreement': _agreement?.toJson(), 'milestone': _milestone?.toJson(), 'raisedBy': _raisedBy?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'reason': _reason,
    'description': _description,
    'evidenceKeys': _evidenceKeys,
    'status': _status,
    'participants': _participants,
    'lastUpdatedBy': _lastUpdatedBy,
    'agreement': _agreement,
    'milestone': _milestone,
    'raisedBy': _raisedBy,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DisputeModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DisputeModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final REASON = amplify_core.QueryField(fieldName: "reason");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final EVIDENCEKEYS = amplify_core.QueryField(fieldName: "evidenceKeys");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final PARTICIPANTS = amplify_core.QueryField(fieldName: "participants");
  static final LASTUPDATEDBY = amplify_core.QueryField(fieldName: "lastUpdatedBy");
  static final AGREEMENT = amplify_core.QueryField(
    fieldName: "agreement",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Agreement'));
  static final MILESTONE = amplify_core.QueryField(
    fieldName: "milestone",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Milestone'));
  static final RAISEDBY = amplify_core.QueryField(
    fieldName: "raisedBy",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Dispute";
    modelSchemaDefinition.pluralName = "Disputes";
    
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
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["agreementId"], name: "disputesByAgreementId"),
      amplify_core.ModelIndex(fields: const ["status"], name: "disputesByStatus")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.REASON,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.DESCRIPTION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.EVIDENCEKEYS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.PARTICIPANTS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.LASTUPDATEDBY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Dispute.AGREEMENT,
      isRequired: false,
      targetNames: ['agreementId'],
      ofModelName: 'Agreement'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Dispute.MILESTONE,
      isRequired: false,
      targetNames: ['milestoneId'],
      ofModelName: 'Milestone'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Dispute.RAISEDBY,
      isRequired: false,
      targetNames: ['raisedById'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Dispute.UPDATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _DisputeModelType extends amplify_core.ModelType<Dispute> {
  const _DisputeModelType();
  
  @override
  Dispute fromJson(Map<String, dynamic> jsonData) {
    return Dispute.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Dispute';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Dispute] in your schema.
 */
class DisputeModelIdentifier implements amplify_core.ModelIdentifier<Dispute> {
  final String id;

  /** Create an instance of DisputeModelIdentifier using [id] the primary key. */
  const DisputeModelIdentifier({
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
  String toString() => 'DisputeModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DisputeModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}