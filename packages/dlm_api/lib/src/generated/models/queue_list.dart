// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'queue.dart';

part 'queue_list.g.dart';

@JsonSerializable()
class QueueList {
  const QueueList({required this.queues, this.schema});

  factory QueueList.fromJson(Map<String, Object?> json) =>
      _$QueueListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Every queue, ordered by position.
  final List<Queue>? queues;

  Map<String, Object?> toJson() => _$QueueListToJson(this);
}
