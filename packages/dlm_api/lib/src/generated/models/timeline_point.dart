// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'timeline_point.g.dart';

@JsonSerializable()
class TimelinePoint {
  const TimelinePoint({
    required this.down,
    required this.time,
    required this.up,
    this.group,
  });

  factory TimelinePoint.fromJson(Map<String, Object?> json) =>
      _$TimelinePointFromJson(json);

  /// Bytes downloaded.
  final int down;

  /// The engine or queue ID when groupBy is set.
  final String? group;

  /// Start of the bucket (UTC).
  final DateTime time;

  /// Bytes uploaded (torrents).
  final int up;

  Map<String, Object?> toJson() => _$TimelinePointToJson(this);
}
