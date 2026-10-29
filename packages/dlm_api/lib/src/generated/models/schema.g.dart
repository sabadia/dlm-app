// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schema _$SchemaFromJson(Map<String, dynamic> json) => Schema(
  fields: (json['fields'] as List<dynamic>?)
      ?.map((e) => FieldSchema.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$SchemaToJson(Schema instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'fields': instance.fields,
};
