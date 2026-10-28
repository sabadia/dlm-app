// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_stats_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletedStatsRow _$CompletedStatsRowFromJson(Map<String, dynamic> json) =>
    CompletedStatsRow(
      bytes: (json['bytes'] as num).toInt(),
      period: CompletedStatsRowPeriod.fromJson(json['period'] as String),
      tasks: (json['tasks'] as num).toInt(),
    );

Map<String, dynamic> _$CompletedStatsRowToJson(CompletedStatsRow instance) =>
    <String, dynamic>{
      'bytes': instance.bytes,
      'period': _$CompletedStatsRowPeriodEnumMap[instance.period]!,
      'tasks': instance.tasks,
    };

const _$CompletedStatsRowPeriodEnumMap = {
  CompletedStatsRowPeriod.value24h: '24h',
  CompletedStatsRowPeriod.value7d: '7d',
  CompletedStatsRowPeriod.value30d: '30d',
  CompletedStatsRowPeriod.$unknown: r'$unknown',
};
