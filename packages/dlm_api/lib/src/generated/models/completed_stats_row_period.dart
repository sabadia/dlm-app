// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// The period ending now.
@JsonEnum()
enum CompletedStatsRowPeriod {
  @JsonValue('24h')
  value24h('24h'),
  @JsonValue('7d')
  value7d('7d'),
  @JsonValue('30d')
  value30d('30d'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CompletedStatsRowPeriod(this.json);

  factory CompletedStatsRowPeriod.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<CompletedStatsRowPeriod> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
