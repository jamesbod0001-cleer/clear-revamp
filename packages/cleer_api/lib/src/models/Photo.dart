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

/** This is an auto generated class representing the Photo type in your schema. */
class Photo {
  final String? _key;
  final String? _blurHash;
  final int? _width;
  final int? _height;
  final String? _altText;

  String get key {
    try {
      return _key!;
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

  String? get blurHash {
    return _blurHash;
  }

  int? get width {
    return _width;
  }

  int? get height {
    return _height;
  }

  String? get altText {
    return _altText;
  }

  const Photo._internal({required key, blurHash, width, height, altText})
    : _key = key,
      _blurHash = blurHash,
      _width = width,
      _height = height,
      _altText = altText;

  factory Photo({
    required String key,
    String? blurHash,
    int? width,
    int? height,
    String? altText,
  }) {
    return Photo._internal(
      key: key,
      blurHash: blurHash,
      width: width,
      height: height,
      altText: altText,
    );
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Photo &&
        _key == other._key &&
        _blurHash == other._blurHash &&
        _width == other._width &&
        _height == other._height &&
        _altText == other._altText;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Photo {");
    buffer.write("key=" + "$_key" + ", ");
    buffer.write("blurHash=" + "$_blurHash" + ", ");
    buffer.write(
      "width=" + (_width != null ? _width.toString() : "null") + ", ",
    );
    buffer.write(
      "height=" + (_height != null ? _height.toString() : "null") + ", ",
    );
    buffer.write("altText=" + "$_altText");
    buffer.write("}");

    return buffer.toString();
  }

  Photo copyWith({
    String? key,
    String? blurHash,
    int? width,
    int? height,
    String? altText,
  }) {
    return Photo._internal(
      key: key ?? this.key,
      blurHash: blurHash ?? this.blurHash,
      width: width ?? this.width,
      height: height ?? this.height,
      altText: altText ?? this.altText,
    );
  }

  Photo copyWithModelFieldValues({
    ModelFieldValue<String>? key,
    ModelFieldValue<String?>? blurHash,
    ModelFieldValue<int?>? width,
    ModelFieldValue<int?>? height,
    ModelFieldValue<String?>? altText,
  }) {
    return Photo._internal(
      key: key == null ? this.key : key.value,
      blurHash: blurHash == null ? this.blurHash : blurHash.value,
      width: width == null ? this.width : width.value,
      height: height == null ? this.height : height.value,
      altText: altText == null ? this.altText : altText.value,
    );
  }

  Photo.fromJson(Map<String, dynamic> json)
    : _key = json['key'],
      _blurHash = json['blurHash'],
      _width = (json['width'] as num?)?.toInt(),
      _height = (json['height'] as num?)?.toInt(),
      _altText = json['altText'];

  Map<String, dynamic> toJson() => {
    'key': _key,
    'blurHash': _blurHash,
    'width': _width,
    'height': _height,
    'altText': _altText,
  };

  Map<String, Object?> toMap() => {
    'key': _key,
    'blurHash': _blurHash,
    'width': _width,
    'height': _height,
    'altText': _altText,
  };

  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "Photo";
      modelSchemaDefinition.pluralName = "Photos";

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
          fieldName: 'key',
          isRequired: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
          fieldName: 'blurHash',
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
          fieldName: 'width',
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
          fieldName: 'height',
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
          fieldName: 'altText',
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
    },
  );
}
