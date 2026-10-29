// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'segment.g.dart';

@JsonSerializable()
class Segment {
  const Segment({
    required this.done,
    required this.end,
    required this.index,
    required this.start,
  });

  factory Segment.fromJson(Map<String, Object?> json) =>
      _$SegmentFromJson(json);

  final int done;
  final int end;
  final int index;
  final int start;

  Map<String, Object?> toJson() => _$SegmentToJson(this);
}
