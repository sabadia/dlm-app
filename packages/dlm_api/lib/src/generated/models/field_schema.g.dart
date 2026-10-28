// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldSchema _$FieldSchemaFromJson(Map<String, dynamic> json) => FieldSchema(
  description: json['description'] as String,
  group: json['group'] as String,
  levels: (json['levels'] as List<dynamic>?)?.map((e) => e as String).toList(),
  path: json['path'] as String,
  type: FieldSchemaType.fromJson(json['type'] as String),
  enumValue: (json['enum'] as List<dynamic>?)?.map((e) => e as String).toList(),
  max: (json['max'] as num?)?.toDouble(),
  min: (json['min'] as num?)?.toDouble(),
  restartRequired: json['restartRequired'] as bool?,
  secret: json['secret'] as bool?,
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$FieldSchemaToJson(FieldSchema instance) =>
    <String, dynamic>{
      'description': instance.description,
      'enum': instance.enumValue,
      'group': instance.group,
      'levels': instance.levels,
      'max': instance.max,
      'min': instance.min,
      'path': instance.path,
      'restartRequired': instance.restartRequired,
      'secret': instance.secret,
      'type': _$FieldSchemaTypeEnumMap[instance.type]!,
      'unit': instance.unit,
    };

const _$FieldSchemaTypeEnumMap = {
  FieldSchemaType.boolean: 'boolean',
  FieldSchemaType.integer: 'integer',
  FieldSchemaType.number: 'number',
  FieldSchemaType.string: 'string',
  FieldSchemaType.duration: 'duration',
  FieldSchemaType.array: 'array',
  FieldSchemaType.object: 'object',
  FieldSchemaType.$unknown: r'$unknown',
};
