// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'task_selector_filter.dart';

part 'delete_tasks_body.g.dart';

@JsonSerializable()
class DeleteTasksBody {
  const DeleteTasksBody({this.schema, this.files, this.filter, this.ids});

  factory DeleteTasksBody.fromJson(Map<String, Object?> json) =>
      _$DeleteTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Also delete the partial and downloaded files.
  final bool? files;

  /// Select tasks by queue and status ({} selects all tasks). Mutually exclusive with ids.
  final TaskSelectorFilter? filter;

  /// Task IDs. Mutually exclusive with filter.
  final List<String>? ids;

  Map<String, Object?> toJson() => _$DeleteTasksBodyToJson(this);
}
