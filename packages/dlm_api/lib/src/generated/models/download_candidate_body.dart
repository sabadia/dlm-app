// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'download_candidate_body_priority.dart';
import 'settings.dart';

part 'download_candidate_body.g.dart';

@JsonSerializable()
class DownloadCandidateBody {
  const DownloadCandidateBody({
    this.schema,
    this.dir,
    this.labels,
    this.name,
    this.paused,
    this.priority,
    this.queueId,
    this.settings,
  });

  factory DownloadCandidateBody.fromJson(Map<String, Object?> json) =>
      _$DownloadCandidateBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Absolute download directory.
  final String? dir;
  final Map<String, String>? labels;

  /// File name without directories (default: the one the page announced).
  final String? name;

  /// Create the task paused instead of queued.
  final bool? paused;
  final DownloadCandidateBodyPriority? priority;

  /// Queue ID or name (default: the Main queue).
  final String? queueId;

  /// Task-level settings overrides.
  final Settings? settings;

  Map<String, Object?> toJson() => _$DownloadCandidateBodyToJson(this);
}
