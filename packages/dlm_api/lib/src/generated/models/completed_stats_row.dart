// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'completed_stats_row_period.dart';

part 'completed_stats_row.g.dart';

@JsonSerializable()
class CompletedStatsRow {
  const CompletedStatsRow({
    required this.bytes,
    required this.period,
    required this.tasks,
  });

  factory CompletedStatsRow.fromJson(Map<String, Object?> json) =>
      _$CompletedStatsRowFromJson(json);

  /// Their size.
  final int bytes;

  /// The period ending now.
  final CompletedStatsRowPeriod period;

  /// Downloads completed in the period.
  final int tasks;

  Map<String, Object?> toJson() => _$CompletedStatsRowToJson(this);
}
