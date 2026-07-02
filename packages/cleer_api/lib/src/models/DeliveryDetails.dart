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


/** This is an auto generated class representing the DeliveryDetails type in your schema. */
class DeliveryDetails {
  final String? _driverPhoneNumber;
  final String? _additionalDetails;
  final List<Photo>? _photos;
  final DeliveryDetailsArrangedBy? _arrangedBy;

  String get driverPhoneNumber {
    try {
      return _driverPhoneNumber!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get additionalDetails {
    return _additionalDetails;
  }
  
  List<Photo>? get photos {
    return _photos;
  }
  
  DeliveryDetailsArrangedBy? get arrangedBy {
    return _arrangedBy;
  }
  
  const DeliveryDetails._internal({required driverPhoneNumber, additionalDetails, photos, arrangedBy}): _driverPhoneNumber = driverPhoneNumber, _additionalDetails = additionalDetails, _photos = photos, _arrangedBy = arrangedBy;
  
  factory DeliveryDetails({required String driverPhoneNumber, String? additionalDetails, List<Photo>? photos, DeliveryDetailsArrangedBy? arrangedBy}) {
    return DeliveryDetails._internal(
      driverPhoneNumber: driverPhoneNumber,
      additionalDetails: additionalDetails,
      photos: photos != null ? List<Photo>.unmodifiable(photos) : photos,
      arrangedBy: arrangedBy);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeliveryDetails &&
      _driverPhoneNumber == other._driverPhoneNumber &&
      _additionalDetails == other._additionalDetails &&
      DeepCollectionEquality().equals(_photos, other._photos) &&
      _arrangedBy == other._arrangedBy;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DeliveryDetails {");
    buffer.write("driverPhoneNumber=" + "$_driverPhoneNumber" + ", ");
    buffer.write("additionalDetails=" + "$_additionalDetails" + ", ");
    buffer.write("photos=" + (_photos != null ? _photos!.toString() : "null") + ", ");
    buffer.write("arrangedBy=" + (_arrangedBy != null ? amplify_core.enumToString(_arrangedBy)! : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DeliveryDetails copyWith({String? driverPhoneNumber, String? additionalDetails, List<Photo>? photos, DeliveryDetailsArrangedBy? arrangedBy}) {
    return DeliveryDetails._internal(
      driverPhoneNumber: driverPhoneNumber ?? this.driverPhoneNumber,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      photos: photos ?? this.photos,
      arrangedBy: arrangedBy ?? this.arrangedBy);
  }
  
  DeliveryDetails copyWithModelFieldValues({
    ModelFieldValue<String>? driverPhoneNumber,
    ModelFieldValue<String?>? additionalDetails,
    ModelFieldValue<List<Photo>?>? photos,
    ModelFieldValue<DeliveryDetailsArrangedBy?>? arrangedBy
  }) {
    return DeliveryDetails._internal(
      driverPhoneNumber: driverPhoneNumber == null ? this.driverPhoneNumber : driverPhoneNumber.value,
      additionalDetails: additionalDetails == null ? this.additionalDetails : additionalDetails.value,
      photos: photos == null ? this.photos : photos.value,
      arrangedBy: arrangedBy == null ? this.arrangedBy : arrangedBy.value
    );
  }
  
  DeliveryDetails.fromJson(Map<String, dynamic> json)  
    : _driverPhoneNumber = json['driverPhoneNumber'],
      _additionalDetails = json['additionalDetails'],
      _photos = json['photos'] is List
        ? (json['photos'] as List)
          .where((e) => e != null)
          .map((e) => Photo.fromJson(new Map<String, dynamic>.from(e['serializedData'] ?? e)))
          .toList()
        : null,
      _arrangedBy = amplify_core.enumFromString<DeliveryDetailsArrangedBy>(json['arrangedBy'], DeliveryDetailsArrangedBy.values);
  
  Map<String, dynamic> toJson() => {
    'driverPhoneNumber': _driverPhoneNumber, 'additionalDetails': _additionalDetails, 'photos': _photos?.map((Photo? e) => e?.toJson()).toList(), 'arrangedBy': amplify_core.enumToString(_arrangedBy)
  };
  
  Map<String, Object?> toMap() => {
    'driverPhoneNumber': _driverPhoneNumber,
    'additionalDetails': _additionalDetails,
    'photos': _photos,
    'arrangedBy': _arrangedBy
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DeliveryDetails";
    modelSchemaDefinition.pluralName = "DeliveryDetails";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'driverPhoneNumber',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'additionalDetails',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'photos',
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embeddedCollection, ofCustomTypeName: 'Photo')
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'arrangedBy',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
  });
}