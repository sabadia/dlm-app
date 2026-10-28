// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptureOutput _$CaptureOutputFromJson(Map<String, dynamic> json) =>
    CaptureOutput(
      cookies: ImportCookiesResult.fromJson(
        json['cookies'] as Map<String, dynamic>,
      ),
      refreshed: json['refreshed'] as bool,
      task: Task.fromJson(json['task'] as Map<String, dynamic>),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$CaptureOutputToJson(CaptureOutput instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'cookies': instance.cookies,
      'refreshed': instance.refreshed,
      'task': instance.task,
    };
