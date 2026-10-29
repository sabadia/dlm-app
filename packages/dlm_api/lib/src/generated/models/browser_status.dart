// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'installation.dart';
import 'running.dart';

part 'browser_status.g.dart';

@JsonSerializable()
class BrowserStatus {
  const BrowserStatus({
    required this.max,
    required this.running,
    this.schema,
    this.browser,
  });

  factory BrowserStatus.fromJson(Map<String, Object?> json) =>
      _$BrowserStatusFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final Installation? browser;
  final int max;
  final List<Running>? running;

  Map<String, Object?> toJson() => _$BrowserStatusToJson(this);
}
