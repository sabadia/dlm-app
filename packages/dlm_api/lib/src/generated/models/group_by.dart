// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Split every bucket by engine or by queue.
@JsonEnum()
enum GroupBy {
  @JsonValue('none')
  none('none'),
  @JsonValue('engine')
  engine('engine'),
  @JsonValue('queue')
  queue('queue'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const GroupBy(this.json);

  factory GroupBy.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<GroupBy> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
