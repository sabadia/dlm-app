// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Installation _$InstallationFromJson(Map<String, dynamic> json) => Installation(
  name: json['name'] as String,
  path: json['path'] as String,
  version: json['version'] as String?,
);

Map<String, dynamic> _$InstallationToJson(Installation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'version': instance.version,
    };
