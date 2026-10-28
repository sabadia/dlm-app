// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  createdAt: DateTime.parse(json['createdAt'] as String),
  downloaded: (json['downloaded'] as num).toInt(),
  id: json['id'] as String,
  position: (json['position'] as num).toInt(),
  priority: json['priority'] as String,
  queueId: json['queueId'] as String,
  settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
  size: (json['size'] as num).toInt(),
  source: Source.fromJson(json['source'] as Map<String, dynamic>),
  status: json['status'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  schema: json[r'$schema'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  dir: json['dir'] as String?,
  engine: json['engine'] as String?,
  error: json['error'] == null
      ? null
      : TaskError.fromJson(json['error'] as Map<String, dynamic>),
  labels: (json['labels'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  name: json['name'] as String?,
  resource: json['resource'] == null
      ? null
      : Resource.fromJson(json['resource'] as Map<String, dynamic>),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'dir': instance.dir,
  'downloaded': instance.downloaded,
  'engine': instance.engine,
  'error': instance.error,
  'id': instance.id,
  'labels': instance.labels,
  'name': instance.name,
  'position': instance.position,
  'priority': instance.priority,
  'queueId': instance.queueId,
  'resource': instance.resource,
  'settings': instance.settings,
  'size': instance.size,
  'source': instance.source,
  'startedAt': instance.startedAt?.toIso8601String(),
  'status': instance.status,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
