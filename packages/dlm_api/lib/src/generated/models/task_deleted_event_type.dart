// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// The event type; also the SSE event name.
@JsonEnum()
enum TaskDeletedEventType {
  /// Incorrect name has been replaced. Original name: `task.deleted`.
  @JsonValue('task.deleted')
  undefined0('task.deleted'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const TaskDeletedEventType(this.json);

  factory TaskDeletedEventType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<TaskDeletedEventType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
