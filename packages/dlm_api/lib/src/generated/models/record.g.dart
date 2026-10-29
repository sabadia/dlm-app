// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) => Record(
  id: (json['id'] as num).toInt(),
  level: RecordLevel.fromJson(json['level'] as String),
  message: json['message'] as String,
  time: DateTime.parse(json['time'] as String),
  attrs: json['attrs'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
  'attrs': instance.attrs,
  'id': instance.id,
  'level': _$RecordLevelEnumMap[instance.level]!,
  'message': instance.message,
  'time': instance.time.toIso8601String(),
};

const _$RecordLevelEnumMap = {
  RecordLevel.debug: 'debug',
  RecordLevel.info: 'info',
  RecordLevel.warn: 'warn',
  RecordLevel.error: 'error',
  RecordLevel.$unknown: r'$unknown',
};
