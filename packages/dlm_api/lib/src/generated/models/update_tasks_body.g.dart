// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTasksBody _$UpdateTasksBodyFromJson(Map<String, dynamic> json) =>
    UpdateTasksBody(
      schema: json[r'$schema'] as String?,
      filter: json['filter'] == null
          ? null
          : TaskSelectorFilter.fromJson(json['filter'] as Map<String, dynamic>),
      ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      labels: (json['labels'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      priority: json['priority'] == null
          ? null
          : UpdateTasksBodyPriority.fromJson(json['priority'] as String),
      queueId: json['queueId'] as String?,
      removeLabels: (json['removeLabels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      settings: json['settings'],
    );

Map<String, dynamic> _$UpdateTasksBodyToJson(UpdateTasksBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'filter': instance.filter,
      'ids': instance.ids,
      'labels': instance.labels,
      'priority': _$UpdateTasksBodyPriorityEnumMap[instance.priority],
      'queueId': instance.queueId,
      'removeLabels': instance.removeLabels,
      'settings': instance.settings,
    };

const _$UpdateTasksBodyPriorityEnumMap = {
  UpdateTasksBodyPriority.low: 'low',
  UpdateTasksBodyPriority.normal: 'normal',
  UpdateTasksBodyPriority.high: 'high',
  UpdateTasksBodyPriority.$unknown: r'$unknown',
};
