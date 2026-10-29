// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'completed_stats_row.dart';
import 'engine_stats_body.dart';

part 'stats_body.g.dart';

@JsonSerializable()
class StatsBody {
  const StatsBody({
    required this.byEngine,
    required this.byStatus,
    required this.completed,
    required this.downloadedBytes,
    required this.tasks,
    this.schema,
  });

  factory StatsBody.fromJson(Map<String, Object?> json) =>
      _$StatsBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Tasks and bytes per protocol engine.
  final List<EngineStatsBody>? byEngine;

  /// Tasks per status; statuses without tasks are absent.
  final Map<String, int> byStatus;

  /// Downloads completed within the last 24 hours, 7 days and 30 days.
  final List<CompletedStatsRow>? completed;

  /// Bytes downloaded by all tasks so far.
  final int downloadedBytes;

  /// Number of tasks.
  final int tasks;

  Map<String, Object?> toJson() => _$StatsBodyToJson(this);
}
