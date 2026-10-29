// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportTasksBody _$ImportTasksBodyFromJson(Map<String, dynamic> json) =>
    ImportTasksBody(
      content: json['content'] as String,
      format: ImportTasksBodyFormat.fromJson(json['format'] as String),
      schema: json[r'$schema'] as String?,
      allowDuplicate: json['allowDuplicate'] as bool?,
      dryRun: json['dryRun'] as bool?,
      expandPatterns: json['expandPatterns'] as bool?,
      paused: json['paused'] as bool?,
      queueId: json['queueId'] as String?,
    );

Map<String, dynamic> _$ImportTasksBodyToJson(ImportTasksBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'allowDuplicate': instance.allowDuplicate,
      'content': instance.content,
      'dryRun': instance.dryRun,
      'expandPatterns': instance.expandPatterns,
      'format': _$ImportTasksBodyFormatEnumMap[instance.format]!,
      'paused': instance.paused,
      'queueId': instance.queueId,
    };

const _$ImportTasksBodyFormatEnumMap = {
  ImportTasksBodyFormat.valueJson: 'json',
  ImportTasksBodyFormat.urls: 'urls',
  ImportTasksBodyFormat.aria2: 'aria2',
  ImportTasksBodyFormat.$unknown: r'$unknown',
};
