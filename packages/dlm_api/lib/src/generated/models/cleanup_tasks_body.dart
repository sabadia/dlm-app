// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'cleanup_tasks_body.g.dart';

@JsonSerializable()
class CleanupTasksBody {
  const CleanupTasksBody({
    required this.olderThanDays,
    this.schema,
    this.dryRun,
    this.files,
    this.queueId,
  });

  factory CleanupTasksBody.fromJson(Map<String, Object?> json) =>
      _$CleanupTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Only count what would be removed.
  final bool? dryRun;

  /// Also delete the downloaded files. Without it only the list entries go.
  final bool? files;

  /// Remove completed tasks that completed at least this many days ago; 0 removes every completed task.
  final int olderThanDays;

  /// Only tasks of this queue (default: all).
  final String? queueId;

  Map<String, Object?> toJson() => _$CleanupTasksBodyToJson(this);
}
