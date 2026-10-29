// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$StreamEventToJson(StreamEvent instance) =>
    <String, dynamic>{};

StreamEventLimitsChangedEvent _$StreamEventLimitsChangedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventLimitsChangedEvent(
  data: LimitsChangedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: LimitsChangedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventLimitsChangedEventToJson(
  StreamEventLimitsChangedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$LimitsChangedEventTypeEnumMap[instance.type]!,
};

const _$LimitsChangedEventTypeEnumMap = {
  LimitsChangedEventType.undefined0: 'limits.changed',
  LimitsChangedEventType.$unknown: r'$unknown',
};

StreamEventPairingRequestedEvent _$StreamEventPairingRequestedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventPairingRequestedEvent(
  data: PairingRequestedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: PairingRequestedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventPairingRequestedEventToJson(
  StreamEventPairingRequestedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$PairingRequestedEventTypeEnumMap[instance.type]!,
};

const _$PairingRequestedEventTypeEnumMap = {
  PairingRequestedEventType.undefined0: 'pairing.requested',
  PairingRequestedEventType.$unknown: r'$unknown',
};

StreamEventPairingResolvedEvent _$StreamEventPairingResolvedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventPairingResolvedEvent(
  data: PairingResolvedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: PairingResolvedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventPairingResolvedEventToJson(
  StreamEventPairingResolvedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$PairingResolvedEventTypeEnumMap[instance.type]!,
};

const _$PairingResolvedEventTypeEnumMap = {
  PairingResolvedEventType.undefined0: 'pairing.resolved',
  PairingResolvedEventType.$unknown: r'$unknown',
};

StreamEventQueueActionCancelledEvent
_$StreamEventQueueActionCancelledEventFromJson(Map<String, dynamic> json) =>
    StreamEventQueueActionCancelledEvent(
      data: ActionCancelledData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
      time: DateTime.parse(json['time'] as String),
      type: QueueActionCancelledEventType.fromJson(json['type'] as String),
    );

Map<String, dynamic> _$StreamEventQueueActionCancelledEventToJson(
  StreamEventQueueActionCancelledEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QueueActionCancelledEventTypeEnumMap[instance.type]!,
};

const _$QueueActionCancelledEventTypeEnumMap = {
  QueueActionCancelledEventType.undefined0: 'queue.action_cancelled',
  QueueActionCancelledEventType.$unknown: r'$unknown',
};

StreamEventQueueCompletedEvent _$StreamEventQueueCompletedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventQueueCompletedEvent(
  data: QueueCompletedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: QueueCompletedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventQueueCompletedEventToJson(
  StreamEventQueueCompletedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QueueCompletedEventTypeEnumMap[instance.type]!,
};

const _$QueueCompletedEventTypeEnumMap = {
  QueueCompletedEventType.undefined0: 'queue.completed',
  QueueCompletedEventType.$unknown: r'$unknown',
};

StreamEventQueueCreatedEvent _$StreamEventQueueCreatedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventQueueCreatedEvent(
  data: Queue.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: QueueCreatedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventQueueCreatedEventToJson(
  StreamEventQueueCreatedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QueueCreatedEventTypeEnumMap[instance.type]!,
};

const _$QueueCreatedEventTypeEnumMap = {
  QueueCreatedEventType.undefined0: 'queue.created',
  QueueCreatedEventType.$unknown: r'$unknown',
};

StreamEventQueueDeletedEvent _$StreamEventQueueDeletedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventQueueDeletedEvent(
  data: Queue.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: QueueDeletedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventQueueDeletedEventToJson(
  StreamEventQueueDeletedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QueueDeletedEventTypeEnumMap[instance.type]!,
};

const _$QueueDeletedEventTypeEnumMap = {
  QueueDeletedEventType.undefined0: 'queue.deleted',
  QueueDeletedEventType.$unknown: r'$unknown',
};

StreamEventQueueUpdatedEvent _$StreamEventQueueUpdatedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventQueueUpdatedEvent(
  data: Queue.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: QueueUpdatedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventQueueUpdatedEventToJson(
  StreamEventQueueUpdatedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QueueUpdatedEventTypeEnumMap[instance.type]!,
};

const _$QueueUpdatedEventTypeEnumMap = {
  QueueUpdatedEventType.undefined0: 'queue.updated',
  QueueUpdatedEventType.$unknown: r'$unknown',
};

StreamEventQuotaExhaustedEvent _$StreamEventQuotaExhaustedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventQuotaExhaustedEvent(
  data: QuotaData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: QuotaExhaustedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventQuotaExhaustedEventToJson(
  StreamEventQuotaExhaustedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QuotaExhaustedEventTypeEnumMap[instance.type]!,
};

const _$QuotaExhaustedEventTypeEnumMap = {
  QuotaExhaustedEventType.undefined0: 'quota.exhausted',
  QuotaExhaustedEventType.$unknown: r'$unknown',
};

StreamEventQuotaResetEvent _$StreamEventQuotaResetEventFromJson(
  Map<String, dynamic> json,
) => StreamEventQuotaResetEvent(
  data: QuotaData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: QuotaResetEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventQuotaResetEventToJson(
  StreamEventQuotaResetEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QuotaResetEventTypeEnumMap[instance.type]!,
};

const _$QuotaResetEventTypeEnumMap = {
  QuotaResetEventType.undefined0: 'quota.reset',
  QuotaResetEventType.$unknown: r'$unknown',
};

StreamEventResourceChangedEvent _$StreamEventResourceChangedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventResourceChangedEvent(
  data: ResourceChangedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: ResourceChangedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventResourceChangedEventToJson(
  StreamEventResourceChangedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$ResourceChangedEventTypeEnumMap[instance.type]!,
};

const _$ResourceChangedEventTypeEnumMap = {
  ResourceChangedEventType.undefined0: 'resource.changed',
  ResourceChangedEventType.$unknown: r'$unknown',
};

StreamEventSettingsUpdatedEvent _$StreamEventSettingsUpdatedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventSettingsUpdatedEvent(
  data: Settings.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: SettingsUpdatedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventSettingsUpdatedEventToJson(
  StreamEventSettingsUpdatedEvent instance,
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

StreamEventSystemSpeedEvent _$StreamEventSystemSpeedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventSystemSpeedEvent(
  data: SpeedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: SystemSpeedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventSystemSpeedEventToJson(
  StreamEventSystemSpeedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$SystemSpeedEventTypeEnumMap[instance.type]!,
};

const _$SystemSpeedEventTypeEnumMap = {
  SystemSpeedEventType.undefined0: 'system.speed',
  SystemSpeedEventType.$unknown: r'$unknown',
};

StreamEventTaskCreatedEvent _$StreamEventTaskCreatedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventTaskCreatedEvent(
  data: Task.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: TaskCreatedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventTaskCreatedEventToJson(
  StreamEventTaskCreatedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskCreatedEventTypeEnumMap[instance.type]!,
};

const _$TaskCreatedEventTypeEnumMap = {
  TaskCreatedEventType.undefined0: 'task.created',
  TaskCreatedEventType.$unknown: r'$unknown',
};

StreamEventTaskDeletedEvent _$StreamEventTaskDeletedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventTaskDeletedEvent(
  data: Task.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: TaskDeletedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventTaskDeletedEventToJson(
  StreamEventTaskDeletedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskDeletedEventTypeEnumMap[instance.type]!,
};

const _$TaskDeletedEventTypeEnumMap = {
  TaskDeletedEventType.undefined0: 'task.deleted',
  TaskDeletedEventType.$unknown: r'$unknown',
};

StreamEventTaskProgressEvent _$StreamEventTaskProgressEventFromJson(
  Map<String, dynamic> json,
) => StreamEventTaskProgressEvent(
  data: ProgressData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: TaskProgressEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventTaskProgressEventToJson(
  StreamEventTaskProgressEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskProgressEventTypeEnumMap[instance.type]!,
};

const _$TaskProgressEventTypeEnumMap = {
  TaskProgressEventType.undefined0: 'task.progress',
  TaskProgressEventType.$unknown: r'$unknown',
};

StreamEventTaskRefreshEvent _$StreamEventTaskRefreshEventFromJson(
  Map<String, dynamic> json,
) => StreamEventTaskRefreshEvent(
  data: RefreshAttempt.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: TaskRefreshEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventTaskRefreshEventToJson(
  StreamEventTaskRefreshEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskRefreshEventTypeEnumMap[instance.type]!,
};

const _$TaskRefreshEventTypeEnumMap = {
  TaskRefreshEventType.undefined0: 'task.refresh',
  TaskRefreshEventType.$unknown: r'$unknown',
};

StreamEventTaskRefreshRequestedEvent
_$StreamEventTaskRefreshRequestedEventFromJson(Map<String, dynamic> json) =>
    StreamEventTaskRefreshRequestedEvent(
      data: RefreshRequestedData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
      time: DateTime.parse(json['time'] as String),
      type: TaskRefreshRequestedEventType.fromJson(json['type'] as String),
    );

Map<String, dynamic> _$StreamEventTaskRefreshRequestedEventToJson(
  StreamEventTaskRefreshRequestedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskRefreshRequestedEventTypeEnumMap[instance.type]!,
};

const _$TaskRefreshRequestedEventTypeEnumMap = {
  TaskRefreshRequestedEventType.undefined0: 'task.refresh.requested',
  TaskRefreshRequestedEventType.$unknown: r'$unknown',
};

StreamEventTaskStatusEvent _$StreamEventTaskStatusEventFromJson(
  Map<String, dynamic> json,
) => StreamEventTaskStatusEvent(
  data: StatusData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: TaskStatusEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventTaskStatusEventToJson(
  StreamEventTaskStatusEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskStatusEventTypeEnumMap[instance.type]!,
};

const _$TaskStatusEventTypeEnumMap = {
  TaskStatusEventType.undefined0: 'task.status',
  TaskStatusEventType.$unknown: r'$unknown',
};

StreamEventTaskUpdatedEvent _$StreamEventTaskUpdatedEventFromJson(
  Map<String, dynamic> json,
) => StreamEventTaskUpdatedEvent(
  data: Task.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
  time: DateTime.parse(json['time'] as String),
  type: TaskUpdatedEventType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StreamEventTaskUpdatedEventToJson(
  StreamEventTaskUpdatedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskUpdatedEventTypeEnumMap[instance.type]!,
};

const _$TaskUpdatedEventTypeEnumMap = {
  TaskUpdatedEventType.undefined0: 'task.updated',
  TaskUpdatedEventType.$unknown: r'$unknown',
};
