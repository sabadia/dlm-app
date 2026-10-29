// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'timeline_point.dart';

part 'timeline.g.dart';

@JsonSerializable()
class Timeline {
  const Timeline({
    required this.bucket,
    required this.from,
    required this.groupBy,
    required this.points,
    required this.to,
    this.schema,
  });

  factory Timeline.fromJson(Map<String, Object?> json) =>
      _$TimelineFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final String bucket;
  final DateTime from;
  final String groupBy;

  /// Oldest first; buckets without traffic are absent.
  final List<TimelinePoint>? points;
  final DateTime to;

  Map<String, Object?> toJson() => _$TimelineToJson(this);
}
