// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTaskBody _$CreateTaskBodyFromJson(Map<String, dynamic> json) =>
    CreateTaskBody(
      schema: json[r'$schema'] as String?,
      allowDuplicate: json['allowDuplicate'] as bool?,
      dir: json['dir'] as String?,
      labels: (json['labels'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      name: json['name'] as String?,
      paused: json['paused'] as bool?,
      priority: json['priority'] == null
          ? null
          : CreateTaskBodyPriority.fromJson(json['priority'] as String),
      queueId: json['queueId'] as String?,
      resolveId: json['resolveId'] as String?,
      settings: json['settings'] == null
          ? null
          : Settings.fromJson(json['settings'] as Map<String, dynamic>),
      source: json['source'] == null
          ? null
          : SourceInput.fromJson(json['source'] as Map<String, dynamic>),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$CreateTaskBodyToJson(CreateTaskBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'allowDuplicate': instance.allowDuplicate,
      'dir': instance.dir,
      'labels': instance.labels,
      'name': instance.name,
      'paused': instance.paused,
      'priority': _$CreateTaskBodyPriorityEnumMap[instance.priority],
      'queueId': instance.queueId,
      'resolveId': instance.resolveId,
      'settings': instance.settings,
      'source': instance.source,
      'url': instance.url,
    };

const _$CreateTaskBodyPriorityEnumMap = {
  CreateTaskBodyPriority.low: 'low',
  CreateTaskBodyPriority.normal: 'normal',
  CreateTaskBodyPriority.high: 'high',
  CreateTaskBodyPriority.$unknown: r'$unknown',
};
