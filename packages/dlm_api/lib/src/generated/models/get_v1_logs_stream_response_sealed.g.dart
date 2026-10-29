// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_logs_stream_response_sealed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$GetV1LogsStreamResponseSealedToJson(
  GetV1LogsStreamResponseSealed instance,
) => <String, dynamic>{};

GetV1LogsStreamResponseSealedRecord
_$GetV1LogsStreamResponseSealedRecordFromJson(Map<String, dynamic> json) =>
    GetV1LogsStreamResponseSealedRecord(
      attrs: json['attrs'] as Map<String, dynamic>?,
      id: (json['id'] as num).toInt(),
      level: RecordLevel.fromJson(json['level'] as String),
      message: json['message'] as String,
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$GetV1LogsStreamResponseSealedRecordToJson(
  GetV1LogsStreamResponseSealedRecord instance,
) => <String, dynamic>{
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

GetV1LogsStreamResponseSealedResetData
_$GetV1LogsStreamResponseSealedResetDataFromJson(Map<String, dynamic> json) =>
    GetV1LogsStreamResponseSealedResetData(
      reason: ResetDataReason.fromJson(json['reason'] as String),
    );

Map<String, dynamic> _$GetV1LogsStreamResponseSealedResetDataToJson(
  GetV1LogsStreamResponseSealedResetData instance,
) => <String, dynamic>{'reason': _$ResetDataReasonEnumMap[instance.reason]!};

const _$ResetDataReasonEnumMap = {
  ResetDataReason.restart: 'restart',
  ResetDataReason.gap: 'gap',
  ResetDataReason.overflow: 'overflow',
  ResetDataReason.$unknown: r'$unknown',
};
