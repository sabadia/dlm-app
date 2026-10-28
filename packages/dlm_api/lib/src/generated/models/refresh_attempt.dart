// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'refresh_attempt.g.dart';

@JsonSerializable()
class RefreshAttempt {
  const RefreshAttempt({
    required this.cause,
    required this.createdAt,
    required this.downloaded,
    required this.id,
    required this.outcome,
    required this.strategy,
    required this.taskId,
    this.deadline,
    this.error,
    this.newUrl,
    this.oldUrl,
  });

  factory RefreshAttempt.fromJson(Map<String, Object?> json) =>
      _$RefreshAttemptFromJson(json);

  final String cause;
  final DateTime createdAt;
  final DateTime? deadline;
  final int downloaded;
  final String? error;
  final String id;
  final String? newUrl;
  final String? oldUrl;
  final String outcome;
  final String strategy;
  final String taskId;

  Map<String, Object?> toJson() => _$RefreshAttemptToJson(this);
}
