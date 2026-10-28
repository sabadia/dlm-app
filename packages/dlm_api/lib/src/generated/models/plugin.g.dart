// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plugin _$PluginFromJson(Map<String, dynamic> json) => Plugin(
  enabled: json['enabled'] as bool,
  hooks: (json['hooks'] as List<dynamic>?)?.map((e) => e as String).toList(),
  installedAt: DateTime.parse(json['installedAt'] as String),
  name: json['name'] as String,
  source: json['source'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  version: json['version'] as String,
  schema: json[r'$schema'] as String?,
  description: json['description'] as String?,
  error: json['error'] as String?,
  net: (json['net'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String?,
);

Map<String, dynamic> _$PluginToJson(Plugin instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'description': instance.description,
  'enabled': instance.enabled,
  'error': instance.error,
  'hooks': instance.hooks,
  'installedAt': instance.installedAt.toIso8601String(),
  'name': instance.name,
  'net': instance.net,
  'source': instance.source,
  'title': instance.title,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'version': instance.version,
};
