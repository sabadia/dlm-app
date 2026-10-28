// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'retry_settings.g.dart';

@JsonSerializable()
class RetrySettings {
  const RetrySettings({
    this.initialBackoff,
    this.maxAttempts,
    this.maxBackoff,
    this.respectRetryAfter,
  });

  factory RetrySettings.fromJson(Map<String, Object?> json) =>
      _$RetrySettingsFromJson(json);

  final String? initialBackoff;
  final int? maxAttempts;
  final String? maxBackoff;
  final bool? respectRetryAfter;

  Map<String, Object?> toJson() => _$RetrySettingsToJson(this);
}
