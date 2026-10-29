// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_task_body.dart';

part 'create_tasks_body.g.dart';

@JsonSerializable()
class CreateTasksBody {
  const CreateTasksBody({
    required this.items,
    this.schema,
    this.expandPatterns,
  });

  factory CreateTasksBody.fromJson(Map<String, Object?> json) =>
      _$CreateTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Expand ranges in the URLs: file[001-100].jpg becomes 100 tasks, [a-e] and [1-10:2] (step) work too, several ranges give every combination (at most 10000 per URL). Results are then one per expanded task, in order; without it the URLs are used as they are.
  final bool? expandPatterns;

  /// Tasks to create.
  final List<CreateTaskBody>? items;

  Map<String, Object?> toJson() => _$CreateTasksBodyToJson(this);
}
