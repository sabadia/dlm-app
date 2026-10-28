// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'exported_tasks.g.dart';

@JsonSerializable()
class ExportedTasks {
  const ExportedTasks({
    required this.content,
    required this.count,
    required this.format,
    this.schema,
  });

  factory ExportedTasks.fromJson(Map<String, Object?> json) =>
      _$ExportedTasksFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The list. Captured headers and cookies are not exported.
  final String content;

  /// How many tasks the list holds.
  final int count;

  /// The format of content.
  final String format;

  Map<String, Object?> toJson() => _$ExportedTasksToJson(this);
}
