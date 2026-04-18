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


/** This is an auto generated class representing the MilestonePreview type in your schema. */
class MilestonePreview {
  final String id;
  final String? _name;
  final double? _amount;
  final int? _order;
  final amplify_core.TemporalDate? _expectedReleaseDate;

  String get name {
    try {
      return _name!;
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
  
  int get order {
    try {
      return _order!;
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
  
  const MilestonePreview._internal({required this.id, required name, required amount, required order, required expectedReleaseDate}): _name = name, _amount = amount, _order = order, _expectedReleaseDate = expectedReleaseDate;
  
  factory MilestonePreview({String? id, required String name, required double amount, required int order, required amplify_core.TemporalDate expectedReleaseDate}) {
    return MilestonePreview._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      amount: amount,
      order: order,
      expectedReleaseDate: expectedReleaseDate);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MilestonePreview &&
      id == other.id &&
      _name == other._name &&
      _amount == other._amount &&
      _order == other._order &&
      _expectedReleaseDate == other._expectedReleaseDate;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("MilestonePreview {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("order=" + (_order != null ? _order!.toString() : "null") + ", ");
    buffer.write("expectedReleaseDate=" + (_expectedReleaseDate != null ? _expectedReleaseDate!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  MilestonePreview copyWith({String? id, String? name, double? amount, int? order, amplify_core.TemporalDate? expectedReleaseDate}) {
    return MilestonePreview._internal(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      order: order ?? this.order,
      expectedReleaseDate: expectedReleaseDate ?? this.expectedReleaseDate);
  }
  
  MilestonePreview copyWithModelFieldValues({
    ModelFieldValue<String>? id,
    ModelFieldValue<String>? name,
    ModelFieldValue<double>? amount,
    ModelFieldValue<int>? order,
    ModelFieldValue<amplify_core.TemporalDate>? expectedReleaseDate
  }) {
    return MilestonePreview._internal(
      id: id == null ? this.id : id.value,
      name: name == null ? this.name : name.value,
      amount: amount == null ? this.amount : amount.value,
      order: order == null ? this.order : order.value,
      expectedReleaseDate: expectedReleaseDate == null ? this.expectedReleaseDate : expectedReleaseDate.value
    );
  }
  
  MilestonePreview.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _order = (json['order'] as num?)?.toInt(),
      _expectedReleaseDate = json['expectedReleaseDate'] != null ? amplify_core.TemporalDate.fromString(json['expectedReleaseDate']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'amount': _amount, 'order': _order, 'expectedReleaseDate': _expectedReleaseDate?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'amount': _amount,
    'order': _order,
    'expectedReleaseDate': _expectedReleaseDate
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "MilestonePreview";
    modelSchemaDefinition.pluralName = "MilestonePreviews";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'id',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'name',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'amount',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'order',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'expectedReleaseDate',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
  });
}