// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'segment.dart';

part 'segment_list.g.dart';

@JsonSerializable()
class SegmentList {
  const SegmentList({required this.segments, this.schema});

  factory SegmentList.fromJson(Map<String, Object?> json) =>
      _$SegmentListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The byte ranges of the download in file order, as last checkpointed (about once a second while the task runs). Empty for engines that do not split the file and for tasks that have not started.
  final List<Segment>? segments;

  Map<String, Object?> toJson() => _$SegmentListToJson(this);
}
