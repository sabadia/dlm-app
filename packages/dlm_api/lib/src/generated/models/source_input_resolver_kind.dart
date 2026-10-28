// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// How the link was obtained (default direct).
@JsonEnum()
enum SourceInputResolverKind {
  @JsonValue('direct')
  direct('direct'),
  @JsonValue('browser')
  browser('browser'),
  @JsonValue('ytdlp')
  ytdlp('ytdlp'),
  @JsonValue('plugin')
  plugin('plugin'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SourceInputResolverKind(this.json);

  factory SourceInputResolverKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<SourceInputResolverKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
