// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_category_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCategoryBody _$CreateCategoryBodyFromJson(Map<String, dynamic> json) =>
    CreateCategoryBody(
      dir: json['dir'] as String,
      name: json['name'] as String,
      schema: json[r'$schema'] as String?,
      extensions: (json['extensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mimeTypes: (json['mimeTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateCategoryBodyToJson(CreateCategoryBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'dir': instance.dir,
      'extensions': instance.extensions,
      'mimeTypes': instance.mimeTypes,
      'name': instance.name,
    };
