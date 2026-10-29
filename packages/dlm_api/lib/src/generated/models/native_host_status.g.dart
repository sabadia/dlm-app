// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_host_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NativeHostStatus _$NativeHostStatusFromJson(Map<String, dynamic> json) =>
    NativeHostStatus(
      allowedOrigins: (json['allowedOrigins'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      browsers: (json['browsers'] as List<dynamic>?)
          ?.map((e) => Result.fromJson(e as Map<String, dynamic>))
          .toList(),
      launcher: json['launcher'] as String,
      launcherExists: json['launcherExists'] as bool,
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$NativeHostStatusToJson(NativeHostStatus instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'allowedOrigins': instance.allowedOrigins,
      'browsers': instance.browsers,
      'launcher': instance.launcher,
      'launcherExists': instance.launcherExists,
    };
