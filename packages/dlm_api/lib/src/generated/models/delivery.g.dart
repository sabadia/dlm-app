// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Delivery _$DeliveryFromJson(Map<String, dynamic> json) => Delivery(
  attempt: (json['attempt'] as num).toInt(),
  durationMs: (json['durationMs'] as num).toInt(),
  event: json['event'] as String,
  eventId: (json['eventId'] as num).toInt(),
  id: (json['id'] as num).toInt(),
  ok: json['ok'] as bool,
  status: (json['status'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  willRetry: json['willRetry'] as bool,
  error: json['error'] as String?,
);

Map<String, dynamic> _$DeliveryToJson(Delivery instance) => <String, dynamic>{
  'attempt': instance.attempt,
  'durationMs': instance.durationMs,
  'error': instance.error,
  'event': instance.event,
  'eventId': instance.eventId,
  'id': instance.id,
  'ok': instance.ok,
  'status': instance.status,
  'time': instance.time.toIso8601String(),
  'willRetry': instance.willRetry,
};
