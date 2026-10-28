// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'task.dart';

part 'task_list.g.dart';

@JsonSerializable()
class TaskList {
  const TaskList({required this.tasks, this.schema, this.nextCursor});

  factory TaskList.fromJson(Map<String, Object?> json) =>
      _$TaskListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Pass as cursor to get the next page; absent on the last page.
  final String? nextCursor;

  /// Tasks of this page.
  final List<Task>? tasks;

  Map<String, Object?> toJson() => _$TaskListToJson(this);
}
