// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_task_body_priority.dart';

part 'update_task_body.g.dart';

@JsonSerializable()
class UpdateTaskBody {
  const UpdateTaskBody({
    this.schema,
    this.dir,
    this.labels,
    this.name,
    this.priority,
    this.settings,
  });

  factory UpdateTaskBody.fromJson(Map<String, Object?> json) =>
      _$UpdateTaskBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// New absolute download directory; empty string resets it to the effective downloadDir.
  final String? dir;

  /// Replaces all labels; {} removes them.
  final Map<String, String>? labels;

  /// New file name (no directories).
  final String? name;

  /// New priority.
  final UpdateTaskBodyPriority? priority;

  /// Merge patch of the task's settings overrides; null values unset fields.
  final dynamic settings;

  Map<String, Object?> toJson() => _$UpdateTaskBodyToJson(this);
}
