// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cleanup_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CleanupTasksBody _$CleanupTasksBodyFromJson(Map<String, dynamic> json) =>
    CleanupTasksBody(
      olderThanDays: (json['olderThanDays'] as num).toInt(),
      schema: json[r'$schema'] as String?,
      dryRun: json['dryRun'] as bool?,
      files: json['files'] as bool?,
      queueId: json['queueId'] as String?,
    );

Map<String, dynamic> _$CleanupTasksBodyToJson(CleanupTasksBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'dryRun': instance.dryRun,
      'files': instance.files,
      'olderThanDays': instance.olderThanDays,
      'queueId': instance.queueId,
    };
