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

/** This is an auto generated class representing the Milestone type in your schema. */
class Milestone extends amplify_core.Model {
  static const classType = const _MilestoneModelType();
  final String id;
  final String? _name;
  final double? _amount;
  final int? _order;
  final amplify_core.TemporalDate? _expectedReleaseDate;
  final List<String>? _participants;
  final String? _lastUpdatedBy;
  final MilestoneStatus? _status;
  final Agreement? _agreement;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
    '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.',
  )
  @override
  String getId() => id;

  MilestoneModelIdentifier get modelIdentifier {
    return MilestoneModelIdentifier(id: id);
  }

  String get name {
    try {
      return _name!;
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

  double get amount {
    try {
      return _amount!;
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

  int get order {
    try {
      return _order!;
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

  amplify_core.TemporalDate get expectedReleaseDate {
    try {
      return _expectedReleaseDate!;
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

  List<String>? get participants {
    return _participants;
  }

  String? get lastUpdatedBy {
    return _lastUpdatedBy;
  }

  MilestoneStatus? get status {
    return _status;
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

  const Milestone._internal({
    required this.id,
    required name,
    required amount,
    required order,
    required expectedReleaseDate,
    participants,
    lastUpdatedBy,
    status,
    agreement,
    createdAt,
    updatedAt,
  }) : _name = name,
       _amount = amount,
       _order = order,
       _expectedReleaseDate = expectedReleaseDate,
       _participants = participants,
       _lastUpdatedBy = lastUpdatedBy,
       _status = status,
       _agreement = agreement,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory Milestone({
    String? id,
    required String name,
    required double amount,
    required int order,
    required amplify_core.TemporalDate expectedReleaseDate,
    List<String>? participants,
    String? lastUpdatedBy,
    MilestoneStatus? status,
    Agreement? agreement,
  }) {
    return Milestone._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      amount: amount,
      order: order,
      expectedReleaseDate: expectedReleaseDate,
      participants: participants != null
          ? List<String>.unmodifiable(participants)
          : participants,
      lastUpdatedBy: lastUpdatedBy,
      status: status,
      agreement: agreement,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Milestone &&
        id == other.id &&
        _name == other._name &&
        _amount == other._amount &&
        _order == other._order &&
        _expectedReleaseDate == other._expectedReleaseDate &&
        DeepCollectionEquality().equals(_participants, other._participants) &&
        _lastUpdatedBy == other._lastUpdatedBy &&
        _status == other._status &&
        _agreement == other._agreement;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Milestone {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write(
      "amount=" + (_amount != null ? _amount.toString() : "null") + ", ",
    );
    buffer.write(
      "order=" + (_order != null ? _order.toString() : "null") + ", ",
    );
    buffer.write(
      "expectedReleaseDate=" +
          (_expectedReleaseDate != null
              ? _expectedReleaseDate.format()
              : "null") +
          ", ",
    );
    buffer.write(
      "participants=" +
          (_participants != null ? _participants.toString() : "null") +
          ", ",
    );
    buffer.write("lastUpdatedBy=" + "$_lastUpdatedBy" + ", ");
    buffer.write(
      "status=" +
          (_status != null ? amplify_core.enumToString(_status)! : "null") +
          ", ",
    );
    buffer.write(
      "agreement=" +
          (_agreement != null ? _agreement.toString() : "null") +
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

  Milestone copyWith({
    String? name,
    double? amount,
    int? order,
    amplify_core.TemporalDate? expectedReleaseDate,
    List<String>? participants,
    String? lastUpdatedBy,
    MilestoneStatus? status,
    Agreement? agreement,
  }) {
    return Milestone._internal(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      order: order ?? this.order,
      expectedReleaseDate: expectedReleaseDate ?? this.expectedReleaseDate,
      participants: participants ?? this.participants,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      status: status ?? this.status,
      agreement: agreement ?? this.agreement,
    );
  }

  Milestone copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<double>? amount,
    ModelFieldValue<int>? order,
    ModelFieldValue<amplify_core.TemporalDate>? expectedReleaseDate,
    ModelFieldValue<List<String>?>? participants,
    ModelFieldValue<String?>? lastUpdatedBy,
    ModelFieldValue<MilestoneStatus?>? status,
    ModelFieldValue<Agreement?>? agreement,
  }) {
    return Milestone._internal(
      id: id,
      name: name == null ? this.name : name.value,
      amount: amount == null ? this.amount : amount.value,
      order: order == null ? this.order : order.value,
      expectedReleaseDate: expectedReleaseDate == null
          ? this.expectedReleaseDate
          : expectedReleaseDate.value,
      participants: participants == null
          ? this.participants
          : participants.value,
      lastUpdatedBy: lastUpdatedBy == null
          ? this.lastUpdatedBy
          : lastUpdatedBy.value,
      status: status == null ? this.status : status.value,
      agreement: agreement == null ? this.agreement : agreement.value,
    );
  }

  Milestone.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _name = json['name'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _order = (json['order'] as num?)?.toInt(),
      _expectedReleaseDate = json['expectedReleaseDate'] != null
          ? amplify_core.TemporalDate.fromString(json['expectedReleaseDate'])
          : null,
      _participants = json['participants']?.cast<String>(),
      _lastUpdatedBy = json['lastUpdatedBy'],
      _status = amplify_core.enumFromString<MilestoneStatus>(
        json['status'],
        MilestoneStatus.values,
      ),
      _agreement = json['agreement'] != null
          ? json['agreement']['serializedData'] != null
                ? Agreement.fromJson(
                    new Map<String, dynamic>.from(
                      json['agreement']['serializedData'],
                    ),
                  )
                : Agreement.fromJson(
                    new Map<String, dynamic>.from(json['agreement']),
                  )
          : null,
      _createdAt = json['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
          : null,
      _updatedAt = json['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': _name,
    'amount': _amount,
    'order': _order,
    'expectedReleaseDate': _expectedReleaseDate?.format(),
    'participants': _participants,
    'lastUpdatedBy': _lastUpdatedBy,
    'status': amplify_core.enumToString(_status),
    'agreement': _agreement?.toJson(),
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'amount': _amount,
    'order': _order,
    'expectedReleaseDate': _expectedReleaseDate,
    'participants': _participants,
    'lastUpdatedBy': _lastUpdatedBy,
    'status': _status,
    'agreement': _agreement,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<MilestoneModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<MilestoneModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final ORDER = amplify_core.QueryField(fieldName: "order");
  static final EXPECTEDRELEASEDATE = amplify_core.QueryField(
    fieldName: "expectedReleaseDate",
  );
  static final PARTICIPANTS = amplify_core.QueryField(
    fieldName: "participants",
  );
  static final LASTUPDATEDBY = amplify_core.QueryField(
    fieldName: "lastUpdatedBy",
  );
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final AGREEMENT = amplify_core.QueryField(
    fieldName: "agreement",
    fieldType: amplify_core.ModelFieldType(
      amplify_core.ModelFieldTypeEnum.model,
      ofModelName: 'Agreement',
    ),
  );
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "Milestone";
      modelSchemaDefinition.pluralName = "Milestones";

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
            amplify_core.ModelOperation.READ,
          ],
        ),
      ];

      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Milestone.NAME,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Milestone.AMOUNT,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.double,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Milestone.ORDER,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Milestone.EXPECTEDRELEASEDATE,
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.date,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Milestone.PARTICIPANTS,
          isRequired: false,
          isArray: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.collection,
            ofModelName: amplify_core.ModelFieldTypeEnum.string.name,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Milestone.LASTUPDATEDBY,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Milestone.STATUS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.enumeration,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.belongsTo(
          key: Milestone.AGREEMENT,
          isRequired: false,
          targetNames: ['agreementId'],
          ofModelName: 'Agreement',
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

class _MilestoneModelType extends amplify_core.ModelType<Milestone> {
  const _MilestoneModelType();

  @override
  Milestone fromJson(Map<String, dynamic> jsonData) {
    return Milestone.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'Milestone';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Milestone] in your schema.
 */
class MilestoneModelIdentifier
    implements amplify_core.ModelIdentifier<Milestone> {
  final String id;

  /** Create an instance of MilestoneModelIdentifier using [id] the primary key. */
  const MilestoneModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'MilestoneModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MilestoneModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
