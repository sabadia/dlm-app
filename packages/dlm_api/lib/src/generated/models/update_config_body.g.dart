// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_config_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateConfigBody _$UpdateConfigBodyFromJson(Map<String, dynamic> json) =>
    UpdateConfigBody(
      values: json['values'] as Map<String, dynamic>,
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$UpdateConfigBodyToJson(UpdateConfigBody instance) =>
    <String, dynamic>{r'$schema': instance.schema, 'values': instance.values};
