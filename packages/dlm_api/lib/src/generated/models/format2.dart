// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// json (dlm's own), urls (one link per line) or aria2 (aria2's input file).
@JsonEnum()
enum Format2 {
  /// The name has been replaced because it contains a keyword. Original name: `json`.
  @JsonValue('json')
  valueJson('json'),
  @JsonValue('urls')
  urls('urls'),
  @JsonValue('aria2')
  aria2('aria2'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const Format2(this.json);

  factory Format2.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<Format2> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
