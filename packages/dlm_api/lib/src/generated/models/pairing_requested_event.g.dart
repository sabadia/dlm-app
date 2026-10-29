// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_requested_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingRequestedEvent _$PairingRequestedEventFromJson(
  Map<String, dynamic> json,
) => PairingRequestedEvent(
  data: PairingRequestedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  type: PairingRequestedEventType.fromJson(json['type'] as String),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
);

Map<String, dynamic> _$PairingRequestedEventToJson(
  PairingRequestedEvent instance,
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
