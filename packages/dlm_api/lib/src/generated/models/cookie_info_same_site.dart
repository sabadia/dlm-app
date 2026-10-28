// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CookieInfoSameSite {
  @JsonValue('lax')
  lax('lax'),
  @JsonValue('strict')
  strict('strict'),
  @JsonValue('none')
  none('none'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CookieInfoSameSite(this.json);

  factory CookieInfoSameSite.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<CookieInfoSameSite> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
