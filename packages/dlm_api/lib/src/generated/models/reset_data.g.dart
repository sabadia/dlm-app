// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetData _$ResetDataFromJson(Map<String, dynamic> json) =>
    ResetData(reason: ResetDataReason.fromJson(json['reason'] as String));

Map<String, dynamic> _$ResetDataToJson(ResetData instance) => <String, dynamic>{
  'reason': _$ResetDataReasonEnumMap[instance.reason]!,
};

const _$ResetDataReasonEnumMap = {
  ResetDataReason.restart: 'restart',
  ResetDataReason.gap: 'gap',
  ResetDataReason.overflow: 'overflow',
  ResetDataReason.$unknown: r'$unknown',
};
