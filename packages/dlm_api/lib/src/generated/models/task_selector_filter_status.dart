// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum TaskSelectorFilterStatus {
  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('paused')
  paused('paused'),
  @JsonValue('awaiting_link')
  awaitingLink('awaiting_link'),
  @JsonValue('refreshing')
  refreshing('refreshing'),
  @JsonValue('postprocessing')
  postprocessing('postprocessing'),
  @JsonValue('completed')
  completed('completed'),
  @JsonValue('error')
  error('error'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const TaskSelectorFilterStatus(this.json);

  factory TaskSelectorFilterStatus.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<TaskSelectorFilterStatus> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
