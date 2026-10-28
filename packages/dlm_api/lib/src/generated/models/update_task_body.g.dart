// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTaskBody _$UpdateTaskBodyFromJson(Map<String, dynamic> json) =>
    UpdateTaskBody(
      schema: json[r'$schema'] as String?,
      dir: json['dir'] as String?,
      labels: (json['labels'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      name: json['name'] as String?,
      priority: json['priority'] == null
          ? null
          : UpdateTaskBodyPriority.fromJson(json['priority'] as String),
      settings: json['settings'],
    );

Map<String, dynamic> _$UpdateTaskBodyToJson(UpdateTaskBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'dir': instance.dir,
      'labels': instance.labels,
      'name': instance.name,
      'priority': _$UpdateTaskBodyPriorityEnumMap[instance.priority],
      'settings': instance.settings,
    };

const _$UpdateTaskBodyPriorityEnumMap = {
  UpdateTaskBodyPriority.low: 'low',
  UpdateTaskBodyPriority.normal: 'normal',
  UpdateTaskBodyPriority.high: 'high',
  UpdateTaskBodyPriority.$unknown: r'$unknown',
};
