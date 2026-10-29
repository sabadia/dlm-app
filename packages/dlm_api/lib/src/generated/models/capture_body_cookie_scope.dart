// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// task keeps the cookies for this download only (they are not in the cookie store and are removed when the task completes or is deleted, or after 7 days); store adds them to the cookie store like cookies/import. Default: task for a browser-extension token, store for any other.
@JsonEnum()
enum CaptureBodyCookieScope {
  @JsonValue('task')
  task('task'),
  @JsonValue('store')
  store('store'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CaptureBodyCookieScope(this.json);

  factory CaptureBodyCookieScope.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<CaptureBodyCookieScope> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
