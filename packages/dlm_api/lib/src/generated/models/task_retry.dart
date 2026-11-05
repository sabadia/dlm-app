// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'task_retry.g.dart';

@JsonSerializable()
class TaskRetry {
  const TaskRetry({
    required this.attempt,
    required this.max,
    required this.nextAt,
  });

  factory TaskRetry.fromJson(Map<String, Object?> json) =>
      _$TaskRetryFromJson(json);

  final int attempt;
  final int max;
  final DateTime nextAt;

  Map<String, Object?> toJson() => _$TaskRetryToJson(this);
}
