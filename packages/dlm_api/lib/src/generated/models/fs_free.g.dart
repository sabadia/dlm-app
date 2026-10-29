// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_free.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FsFree _$FsFreeFromJson(Map<String, dynamic> json) => FsFree(
  freeBytes: (json['freeBytes'] as num).toInt(),
  path: json['path'] as String,
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$FsFreeToJson(FsFree instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'freeBytes': instance.freeBytes,
  'path': instance.path,
};
