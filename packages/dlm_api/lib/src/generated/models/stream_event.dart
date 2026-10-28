// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'action_cancelled_data.dart';
import 'progress_data.dart';
import 'queue.dart';
import 'queue_action_cancelled_event.dart';
import 'queue_action_cancelled_event_type.dart';
import 'queue_completed_data.dart';
import 'queue_completed_event.dart';
import 'queue_completed_event_type.dart';
import 'queue_created_event.dart';
import 'queue_created_event_type.dart';
import 'queue_deleted_event.dart';
import 'queue_deleted_event_type.dart';
import 'queue_updated_event.dart';
import 'queue_updated_event_type.dart';
import 'quota_data.dart';
import 'quota_exhausted_event.dart';
import 'quota_exhausted_event_type.dart';
import 'quota_reset_event.dart';
import 'quota_reset_event_type.dart';
import 'refresh_attempt.dart';
import 'settings.dart';
import 'settings_updated_event.dart';
import 'settings_updated_event_type.dart';
import 'status_data.dart';
import 'task.dart';
import 'task_created_event.dart';
import 'task_created_event_type.dart';
import 'task_deleted_event.dart';
import 'task_deleted_event_type.dart';
import 'task_progress_event.dart';
import 'task_progress_event_type.dart';
import 'task_refresh_event.dart';
import 'task_refresh_event_type.dart';
import 'task_status_event.dart';
import 'task_status_event_type.dart';
import 'task_updated_event.dart';
import 'task_updated_event_type.dart';

part 'stream_event.g.dart';

/// An event of the stream: one of the typed events, told apart by type.
@JsonSerializable(createFactory: false)
sealed class StreamEvent {
  const StreamEvent();

  factory StreamEvent.fromJson(Map<String, dynamic> json) =>
      StreamEventSealedDeserializer.tryDeserialize(json);

  Map<String, dynamic> toJson();
}

extension StreamEventSealedDeserializer on StreamEvent {
  static StreamEvent tryDeserialize(
    Map<String, dynamic> json, {
    String key = 'type',
    Map<Type, Object?>? mapping,
  }) {
    final mappingFallback = const <Type, Object?>{
      StreamEventQueueActionCancelledEvent: 'queue.action_cancelled',
      StreamEventQueueCompletedEvent: 'queue.completed',
      StreamEventQueueCreatedEvent: 'queue.created',
      StreamEventQueueDeletedEvent: 'queue.deleted',
      StreamEventQueueUpdatedEvent: 'queue.updated',
      StreamEventQuotaExhaustedEvent: 'quota.exhausted',
      StreamEventQuotaResetEvent: 'quota.reset',
      StreamEventSettingsUpdatedEvent: 'settings.updated',
      StreamEventTaskCreatedEvent: 'task.created',
      StreamEventTaskDeletedEvent: 'task.deleted',
      StreamEventTaskProgressEvent: 'task.progress',
      StreamEventTaskRefreshEvent: 'task.refresh',
      StreamEventTaskStatusEvent: 'task.status',
      StreamEventTaskUpdatedEvent: 'task.updated',
    };
    final value = json[key];
    final effective = mapping ?? mappingFallback;
    return switch (value) {
      _ when value == effective[StreamEventQueueActionCancelledEvent] =>
        StreamEventQueueActionCancelledEvent.fromJson(json),
      _ when value == effective[StreamEventQueueCompletedEvent] =>
        StreamEventQueueCompletedEvent.fromJson(json),
      _ when value == effective[StreamEventQueueCreatedEvent] =>
        StreamEventQueueCreatedEvent.fromJson(json),
      _ when value == effective[StreamEventQueueDeletedEvent] =>
        StreamEventQueueDeletedEvent.fromJson(json),
      _ when value == effective[StreamEventQueueUpdatedEvent] =>
        StreamEventQueueUpdatedEvent.fromJson(json),
      _ when value == effective[StreamEventQuotaExhaustedEvent] =>
        StreamEventQuotaExhaustedEvent.fromJson(json),
      _ when value == effective[StreamEventQuotaResetEvent] =>
        StreamEventQuotaResetEvent.fromJson(json),
      _ when value == effective[StreamEventSettingsUpdatedEvent] =>
        StreamEventSettingsUpdatedEvent.fromJson(json),
      _ when value == effective[StreamEventTaskCreatedEvent] =>
        StreamEventTaskCreatedEvent.fromJson(json),
      _ when value == effective[StreamEventTaskDeletedEvent] =>
        StreamEventTaskDeletedEvent.fromJson(json),
      _ when value == effective[StreamEventTaskProgressEvent] =>
        StreamEventTaskProgressEvent.fromJson(json),
      _ when value == effective[StreamEventTaskRefreshEvent] =>
        StreamEventTaskRefreshEvent.fromJson(json),
      _ when value == effective[StreamEventTaskStatusEvent] =>
        StreamEventTaskStatusEvent.fromJson(json),
      _ when value == effective[StreamEventTaskUpdatedEvent] =>
        StreamEventTaskUpdatedEvent.fromJson(json),
      _ => throw FormatException(
        'Unknown discriminator value "${json[key]}" for StreamEvent',
      ),
    };
  }
}

@JsonSerializable()
class StreamEventQueueActionCancelledEvent extends StreamEvent
    implements QueueActionCancelledEvent {
  @override
  final ActionCancelledData data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final QueueActionCancelledEventType type;

  const StreamEventQueueActionCancelledEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventQueueActionCancelledEvent.fromJson(
    Map<String, dynamic> json,
  ) => _$StreamEventQueueActionCancelledEventFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$StreamEventQueueActionCancelledEventToJson(this);
}

@JsonSerializable()
class StreamEventQueueCompletedEvent extends StreamEvent
    implements QueueCompletedEvent {
  @override
  final QueueCompletedData data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final QueueCompletedEventType type;

  const StreamEventQueueCompletedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventQueueCompletedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventQueueCompletedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventQueueCompletedEventToJson(this);
}

@JsonSerializable()
class StreamEventQueueCreatedEvent extends StreamEvent
    implements QueueCreatedEvent {
  @override
  final Queue data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final QueueCreatedEventType type;

  const StreamEventQueueCreatedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventQueueCreatedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventQueueCreatedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventQueueCreatedEventToJson(this);
}

@JsonSerializable()
class StreamEventQueueDeletedEvent extends StreamEvent
    implements QueueDeletedEvent {
  @override
  final Queue data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final QueueDeletedEventType type;

  const StreamEventQueueDeletedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventQueueDeletedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventQueueDeletedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventQueueDeletedEventToJson(this);
}

@JsonSerializable()
class StreamEventQueueUpdatedEvent extends StreamEvent
    implements QueueUpdatedEvent {
  @override
  final Queue data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final QueueUpdatedEventType type;

  const StreamEventQueueUpdatedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventQueueUpdatedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventQueueUpdatedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventQueueUpdatedEventToJson(this);
}

@JsonSerializable()
class StreamEventQuotaExhaustedEvent extends StreamEvent
    implements QuotaExhaustedEvent {
  @override
  final QuotaData data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final QuotaExhaustedEventType type;

  const StreamEventQuotaExhaustedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventQuotaExhaustedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventQuotaExhaustedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventQuotaExhaustedEventToJson(this);
}

@JsonSerializable()
class StreamEventQuotaResetEvent extends StreamEvent
    implements QuotaResetEvent {
  @override
  final QuotaData data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final QuotaResetEventType type;

  const StreamEventQuotaResetEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventQuotaResetEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventQuotaResetEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventQuotaResetEventToJson(this);
}

@JsonSerializable()
class StreamEventSettingsUpdatedEvent extends StreamEvent
    implements SettingsUpdatedEvent {
  @override
  final Settings data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final SettingsUpdatedEventType type;

  const StreamEventSettingsUpdatedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventSettingsUpdatedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventSettingsUpdatedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$StreamEventSettingsUpdatedEventToJson(this);
}

@JsonSerializable()
class StreamEventTaskCreatedEvent extends StreamEvent
    implements TaskCreatedEvent {
  @override
  final Task data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final TaskCreatedEventType type;

  const StreamEventTaskCreatedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventTaskCreatedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventTaskCreatedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventTaskCreatedEventToJson(this);
}

@JsonSerializable()
class StreamEventTaskDeletedEvent extends StreamEvent
    implements TaskDeletedEvent {
  @override
  final Task data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final TaskDeletedEventType type;

  const StreamEventTaskDeletedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventTaskDeletedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventTaskDeletedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventTaskDeletedEventToJson(this);
}

@JsonSerializable()
class StreamEventTaskProgressEvent extends StreamEvent
    implements TaskProgressEvent {
  @override
  final ProgressData data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final TaskProgressEventType type;

  const StreamEventTaskProgressEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventTaskProgressEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventTaskProgressEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventTaskProgressEventToJson(this);
}

@JsonSerializable()
class StreamEventTaskRefreshEvent extends StreamEvent
    implements TaskRefreshEvent {
  @override
  final RefreshAttempt data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final TaskRefreshEventType type;

  const StreamEventTaskRefreshEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventTaskRefreshEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventTaskRefreshEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventTaskRefreshEventToJson(this);
}

@JsonSerializable()
class StreamEventTaskStatusEvent extends StreamEvent
    implements TaskStatusEvent {
  @override
  final StatusData data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final TaskStatusEventType type;

  const StreamEventTaskStatusEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventTaskStatusEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventTaskStatusEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventTaskStatusEventToJson(this);
}

@JsonSerializable()
class StreamEventTaskUpdatedEvent extends StreamEvent
    implements TaskUpdatedEvent {
  @override
  final Task data;
  @override
  final int id;
  @override
  final String? queueId;
  @override
  final String? taskId;
  @override
  final DateTime time;
  @override
  final TaskUpdatedEventType type;

  const StreamEventTaskUpdatedEvent({
    required this.data,
    required this.id,
    required this.queueId,
    required this.taskId,
    required this.time,
    required this.type,
  });

  factory StreamEventTaskUpdatedEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventTaskUpdatedEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StreamEventTaskUpdatedEventToJson(this);
}
