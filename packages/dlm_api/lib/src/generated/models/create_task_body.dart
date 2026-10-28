// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_task_body_priority.dart';
import 'settings.dart';
import 'source_input.dart';

part 'create_task_body.g.dart';

@JsonSerializable()
class CreateTaskBody {
  const CreateTaskBody({
    this.schema,
    this.allowDuplicate,
    this.dir,
    this.labels,
    this.name,
    this.paused,
    this.priority,
    this.queueId,
    this.resolveId,
    this.settings,
    this.source,
    this.url,
  });

  factory CreateTaskBody.fromJson(Map<String, Object?> json) =>
      _$CreateTaskBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Add the task even when another task has the same link, expected checksum, or (once resolved) file name and size; otherwise it is refused with 409.
  final bool? allowDuplicate;

  /// Absolute download directory (default: the effective downloadDir).
  final String? dir;

  /// Free-form labels.
  final Map<String, String>? labels;

  /// File name without directories (default: the suggested name).
  final String? name;

  /// Create the task paused instead of queued.
  final bool? paused;

  /// Priority within the queue (default normal).
  final CreateTaskBodyPriority? priority;

  /// Queue to add the task to (default: the Main queue).
  final String? queueId;

  /// ID of a resolve-task result; its probe is reused and url/source are ignored.
  final String? resolveId;

  /// Task-level settings overrides.
  final Settings? settings;

  /// Full source description. Mutually exclusive with url.
  final SourceInput? source;

  /// URL to download; shorthand for source.currentUrl. Mutually exclusive with source.
  final String? url;

  Map<String, Object?> toJson() => _$CreateTaskBodyToJson(this);
}
