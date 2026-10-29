// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'import_tasks_body_format.dart';

part 'import_tasks_body.g.dart';

@JsonSerializable()
class ImportTasksBody {
  const ImportTasksBody({
    required this.content,
    required this.format,
    this.schema,
    this.allowDuplicate,
    this.dryRun,
    this.expandPatterns,
    this.paused,
    this.queueId,
  });

  factory ImportTasksBody.fromJson(Map<String, Object?> json) =>
      _$ImportTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Add tasks even when another task has the same link, checksum, or file name and size.
  final bool? allowDuplicate;

  /// The list to import (at most 8 MiB and 10000 entries).
  final String content;

  /// Create nothing: answer, per entry, whether it would be added (ok) or why not (an invalid link, a duplicate of an existing task's link).
  final bool? dryRun;

  /// Expand ranges in the URLs: file[001-100].jpg becomes 100 tasks.
  final bool? expandPatterns;

  /// Format of content.
  final ImportTasksBodyFormat format;

  /// Add the tasks paused.
  final bool? paused;

  /// Queue to add the tasks to (default: the Main queue).
  final String? queueId;

  Map<String, Object?> toJson() => _$ImportTasksBodyToJson(this);
}
