// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'refresh_attempt.dart';

part 'refresh_history.g.dart';

@JsonSerializable()
class RefreshHistory {
  const RefreshHistory({required this.attempts, this.schema});

  factory RefreshHistory.fromJson(Map<String, Object?> json) =>
      _$RefreshHistoryFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The task's refresh history, oldest first.
  final List<RefreshAttempt>? attempts;

  Map<String, Object?> toJson() => _$RefreshHistoryToJson(this);
}
