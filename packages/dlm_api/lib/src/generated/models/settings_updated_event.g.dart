// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_updated_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsUpdatedEvent _$SettingsUpdatedEventFromJson(
  Map<String, dynamic> json,
) => SettingsUpdatedEvent(
  data: Settings.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  type: SettingsUpdatedEventType.fromJson(json['type'] as String),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
);

Map<String, dynamic> _$SettingsUpdatedEventToJson(
  SettingsUpdatedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$SettingsUpdatedEventTypeEnumMap[instance.type]!,
};

const _$SettingsUpdatedEventTypeEnumMap = {
  SettingsUpdatedEventType.undefined0: 'settings.updated',
  SettingsUpdatedEventType.$unknown: r'$unknown',
};
