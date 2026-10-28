// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'task_selector_filter_status.dart';

part 'task_selector_filter.g.dart';

@JsonSerializable()
class TaskSelectorFilter {
  const TaskSelectorFilter({this.queueId, this.status});

  factory TaskSelectorFilter.fromJson(Map<String, Object?> json) =>
      _$TaskSelectorFilterFromJson(json);

  /// Only tasks of this queue.
  final String? queueId;

  /// Only tasks in any of these states.
  final List<TaskSelectorFilterStatus>? status;

  Map<String, Object?> toJson() => _$TaskSelectorFilterToJson(this);
}
