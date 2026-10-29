// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'task_selector_filter.dart';

part 'move_tasks_body.g.dart';

@JsonSerializable()
class MoveTasksBody {
  const MoveTasksBody({
    required this.queueId,
    this.schema,
    this.filter,
    this.ids,
  });

  factory MoveTasksBody.fromJson(Map<String, Object?> json) =>
      _$MoveTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Select tasks by queue and status ({} selects all tasks). Mutually exclusive with ids.
  final TaskSelectorFilter? filter;

  /// Task IDs. Mutually exclusive with filter.
  final List<String>? ids;

  /// Target queue ID; the tasks go to its end.
  final String queueId;

  Map<String, Object?> toJson() => _$MoveTasksBodyToJson(this);
}
