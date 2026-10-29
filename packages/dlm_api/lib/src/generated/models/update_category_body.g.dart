// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_category_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCategoryBody _$UpdateCategoryBodyFromJson(Map<String, dynamic> json) =>
    UpdateCategoryBody(
      schema: json[r'$schema'] as String?,
      dir: json['dir'] as String?,
      extensions: (json['extensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mimeTypes: (json['mimeTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      name: json['name'] as String?,
      position: (json['position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateCategoryBodyToJson(UpdateCategoryBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'dir': instance.dir,
      'extensions': instance.extensions,
      'mimeTypes': instance.mimeTypes,
      'name': instance.name,
      'position': instance.position,
    };
