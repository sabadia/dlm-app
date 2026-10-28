// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'task_error.g.dart';

@JsonSerializable()
class TaskError {
  const TaskError({
    required this.at,
    required this.code,
    required this.message,
    required this.retryable,
  });

  factory TaskError.fromJson(Map<String, Object?> json) =>
      _$TaskErrorFromJson(json);

  final DateTime at;
  final String code;
  final String message;
  final bool retryable;

  Map<String, Object?> toJson() => _$TaskErrorToJson(this);
}
