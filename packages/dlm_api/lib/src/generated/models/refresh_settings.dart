// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'refresh_settings.g.dart';

@JsonSerializable()
class RefreshSettings {
  const RefreshSettings({
    this.auto,
    this.awaitTimeout,
    this.maxAttempts,
    this.onMismatch,
    this.strategies,
  });

  factory RefreshSettings.fromJson(Map<String, Object?> json) =>
      _$RefreshSettingsFromJson(json);

  final bool? auto;
  final String? awaitTimeout;
  final int? maxAttempts;
  final String? onMismatch;
  final List<String>? strategies;

  Map<String, Object?> toJson() => _$RefreshSettingsToJson(this);
}
