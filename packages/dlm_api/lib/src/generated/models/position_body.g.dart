// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PositionBody _$PositionBodyFromJson(Map<String, dynamic> json) => PositionBody(
  position: (json['position'] as num).toInt(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$PositionBodyToJson(PositionBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'position': instance.position,
    };
