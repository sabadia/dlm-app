// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemInfo _$SystemInfoFromJson(Map<String, dynamic> json) => SystemInfo(
  address: json['address'] as String,
  apiVersion: (json['apiVersion'] as num).toInt(),
  arch: json['arch'] as String,
  databaseBytes: (json['databaseBytes'] as num).toInt(),
  engines: (json['engines'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  fsRoots: (json['fsRoots'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  goVersion: json['goVersion'] as String,
  local: json['local'] as bool,
  minClientApi: (json['minClientApi'] as num).toInt(),
  os: json['os'] as String,
  paths: SystemPaths.fromJson(json['paths'] as Map<String, dynamic>),
  pid: (json['pid'] as num).toInt(),
  startedAt: DateTime.parse(json['startedAt'] as String),
  tls: json['tls'] as bool,
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => ToolStatus.fromJson(e as Map<String, dynamic>))
      .toList(),
  uptimeSeconds: (json['uptimeSeconds'] as num).toInt(),
  version: json['version'] as String,
  schema: json[r'$schema'] as String?,
  commit: json['commit'] as String?,
);

Map<String, dynamic> _$SystemInfoToJson(SystemInfo instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'address': instance.address,
      'apiVersion': instance.apiVersion,
      'arch': instance.arch,
      'commit': instance.commit,
      'databaseBytes': instance.databaseBytes,
      'engines': instance.engines,
      'fsRoots': instance.fsRoots,
      'goVersion': instance.goVersion,
      'local': instance.local,
      'minClientApi': instance.minClientApi,
      'os': instance.os,
      'paths': instance.paths,
      'pid': instance.pid,
      'startedAt': instance.startedAt.toIso8601String(),
      'tls': instance.tls,
      'tools': instance.tools,
      'uptimeSeconds': instance.uptimeSeconds,
      'version': instance.version,
    };
