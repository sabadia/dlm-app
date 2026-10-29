// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'task_selector_filter.dart';
import 'update_tasks_body_priority.dart';

part 'update_tasks_body.g.dart';

@JsonSerializable()
class UpdateTasksBody {
  const UpdateTasksBody({
    this.schema,
    this.filter,
    this.ids,
    this.labels,
    this.priority,
    this.queueId,
    this.removeLabels,
    this.settings,
  });

  factory UpdateTasksBody.fromJson(Map<String, Object?> json) =>
      _$UpdateTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Select tasks by queue and status ({} selects all tasks). Mutually exclusive with ids.
  final TaskSelectorFilter? filter;

  /// Task IDs. Mutually exclusive with filter.
  final List<String>? ids;

  /// Labels to add or change; the other labels of each task stay.
  final Map<String, String>? labels;

  /// New priority.
  final UpdateTasksBodyPriority? priority;

  /// Also move the tasks to this queue.
  final String? queueId;

  /// Labels to drop (by key).
  final List<String>? removeLabels;

  /// Merge patch of each task's settings overrides; null values unset fields.
  final dynamic settings;

  Map<String, Object?> toJson() => _$UpdateTasksBodyToJson(this);
}
