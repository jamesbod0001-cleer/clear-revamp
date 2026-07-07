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


/** This is an auto generated class representing the PhysicalDeliveryContext type in your schema. */
class PhysicalDeliveryContext {
  final PhysicalDeliveryContextStatus? _status;
  final List<Photo>? _packagingPhotos;
  final DeliveryDetails? _deliveryDetails;

  PhysicalDeliveryContextStatus? get status {
    return _status;
  }
  
  List<Photo>? get packagingPhotos {
    return _packagingPhotos;
  }
  
  DeliveryDetails? get deliveryDetails {
    return _deliveryDetails;
  }
  
  const PhysicalDeliveryContext._internal({status, packagingPhotos, deliveryDetails}): _status = status, _packagingPhotos = packagingPhotos, _deliveryDetails = deliveryDetails;
  
  factory PhysicalDeliveryContext({PhysicalDeliveryContextStatus? status, List<Photo>? packagingPhotos, DeliveryDetails? deliveryDetails}) {
    return PhysicalDeliveryContext._internal(
      status: status,
      packagingPhotos: packagingPhotos != null ? List<Photo>.unmodifiable(packagingPhotos) : packagingPhotos,
      deliveryDetails: deliveryDetails);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhysicalDeliveryContext &&
      _status == other._status &&
      DeepCollectionEquality().equals(_packagingPhotos, other._packagingPhotos) &&
      _deliveryDetails == other._deliveryDetails;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("PhysicalDeliveryContext {");
    buffer.write("status=" + (_status != null ? amplify_core.enumToString(_status)! : "null") + ", ");
    buffer.write("packagingPhotos=" + (_packagingPhotos != null ? _packagingPhotos!.toString() : "null") + ", ");
    buffer.write("deliveryDetails=" + (_deliveryDetails != null ? _deliveryDetails!.toString() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  PhysicalDeliveryContext copyWith({PhysicalDeliveryContextStatus? status, List<Photo>? packagingPhotos, DeliveryDetails? deliveryDetails}) {
    return PhysicalDeliveryContext._internal(
      status: status ?? this.status,
      packagingPhotos: packagingPhotos ?? this.packagingPhotos,
      deliveryDetails: deliveryDetails ?? this.deliveryDetails);
  }
  
  PhysicalDeliveryContext copyWithModelFieldValues({
    ModelFieldValue<PhysicalDeliveryContextStatus?>? status,
    ModelFieldValue<List<Photo>?>? packagingPhotos,
    ModelFieldValue<DeliveryDetails?>? deliveryDetails
  }) {
    return PhysicalDeliveryContext._internal(
      status: status == null ? this.status : status.value,
      packagingPhotos: packagingPhotos == null ? this.packagingPhotos : packagingPhotos.value,
      deliveryDetails: deliveryDetails == null ? this.deliveryDetails : deliveryDetails.value
    );
  }
  
  PhysicalDeliveryContext.fromJson(Map<String, dynamic> json)  
    : _status = amplify_core.enumFromString<PhysicalDeliveryContextStatus>(json['status'], PhysicalDeliveryContextStatus.values),
      _packagingPhotos = json['packagingPhotos'] is List
        ? (json['packagingPhotos'] as List)
          .where((e) => e != null)
          .map((e) => Photo.fromJson(new Map<String, dynamic>.from(e['serializedData'] ?? e)))
          .toList()
        : null,
      _deliveryDetails = json['deliveryDetails'] != null
          ? json['deliveryDetails']['serializedData'] != null
              ? DeliveryDetails.fromJson(new Map<String, dynamic>.from(json['deliveryDetails']['serializedData']))
              : DeliveryDetails.fromJson(new Map<String, dynamic>.from(json['deliveryDetails']))
        : null;
  
  Map<String, dynamic> toJson() => {
    'status': amplify_core.enumToString(_status), 'packagingPhotos': _packagingPhotos?.map((Photo? e) => e?.toJson()).toList(), 'deliveryDetails': _deliveryDetails?.toJson()
  };
  
  Map<String, Object?> toMap() => {
    'status': _status,
    'packagingPhotos': _packagingPhotos,
    'deliveryDetails': _deliveryDetails
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PhysicalDeliveryContext";
    modelSchemaDefinition.pluralName = "PhysicalDeliveryContexts";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'status',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'packagingPhotos',
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embeddedCollection, ofCustomTypeName: 'Photo')
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.embedded(
      fieldName: 'deliveryDetails',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.embedded, ofCustomTypeName: 'DeliveryDetails')
    ));
  });
}