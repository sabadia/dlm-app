// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'engine_stats_body.g.dart';

@JsonSerializable()
class EngineStatsBody {
  const EngineStatsBody({
    required this.downloadedBytes,
    required this.engine,
    required this.tasks,
  });

  factory EngineStatsBody.fromJson(Map<String, Object?> json) =>
      _$EngineStatsBodyFromJson(json);

  /// Bytes downloaded by them.
  final int downloadedBytes;

  /// Engine name: http, ftp, hls, dash, bt, ed2k, ytdlp, ...
  final String engine;

  /// Number of tasks.
  final int tasks;

  Map<String, Object?> toJson() => _$EngineStatsBodyToJson(this);
}
