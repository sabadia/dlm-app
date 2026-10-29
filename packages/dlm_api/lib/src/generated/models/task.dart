// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resource.dart';
import 'settings.dart';
import 'source.dart';
import 'task_error.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  const Task({
    required this.createdAt,
    required this.downloaded,
    required this.id,
    required this.position,
    required this.priority,
    required this.queueId,
    required this.settings,
    required this.size,
    required this.source,
    required this.status,
    required this.updatedAt,
    this.schema,
    this.completedAt,
    this.dir,
    this.engine,
    this.error,
    this.labels,
    this.name,
    this.resource,
    this.startedAt,
  });

  factory Task.fromJson(Map<String, Object?> json) => _$TaskFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final DateTime? completedAt;
  final DateTime createdAt;
  final String? dir;
  final int downloaded;
  final String? engine;
  final TaskError? error;
  final String id;
  final Map<String, String>? labels;
  final String? name;
  final int position;
  final String priority;
  final String queueId;
  final Resource? resource;
  final Settings settings;
  final int size;
  final Source source;
  final DateTime? startedAt;
  final String status;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$TaskToJson(this);
}
