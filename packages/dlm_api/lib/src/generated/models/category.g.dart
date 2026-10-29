// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  dir: json['dir'] as String,
  id: json['id'] as String,
  name: json['name'] as String,
  position: (json['position'] as num).toInt(),
  schema: json[r'$schema'] as String?,
  extensions: (json['extensions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  mimeTypes: (json['mimeTypes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'dir': instance.dir,
  'extensions': instance.extensions,
  'id': instance.id,
  'mimeTypes': instance.mimeTypes,
  'name': instance.name,
  'position': instance.position,
};
