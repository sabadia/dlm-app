// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'import_cookies_result.dart';
import 'task.dart';

part 'capture_output.g.dart';

@JsonSerializable()
class CaptureOutput {
  const CaptureOutput({
    required this.cookies,
    required this.refreshed,
    required this.task,
    this.schema,
  });

  factory CaptureOutput.fromJson(Map<String, Object?> json) =>
      _$CaptureOutputFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Result of storing the request's cookies.
  final ImportCookiesResult cookies;

  /// True when the capture matched a task that was waiting for a new link and gave it the link instead of creating a task.
  final bool refreshed;

  /// The created task, or the existing task that received the captured link.
  final Task task;

  Map<String, Object?> toJson() => _$CaptureOutputToJson(this);
}
