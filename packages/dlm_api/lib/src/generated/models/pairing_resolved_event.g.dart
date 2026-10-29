// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_resolved_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingResolvedEvent _$PairingResolvedEventFromJson(
  Map<String, dynamic> json,
) => PairingResolvedEvent(
  data: PairingResolvedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  type: PairingResolvedEventType.fromJson(json['type'] as String),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
);

Map<String, dynamic> _$PairingResolvedEventToJson(
  PairingResolvedEvent instance,
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
