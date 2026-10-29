// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Format of data; detected from the content when absent.
@JsonEnum()
enum ImportCookiesBodyFormat {
  /// The name has been replaced because it contains a keyword. Original name: `json`.
  @JsonValue('json')
  valueJson('json'),
  @JsonValue('netscape')
  netscape('netscape'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ImportCookiesBodyFormat(this.json);

  factory ImportCookiesBodyFormat.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<ImportCookiesBodyFormat> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
