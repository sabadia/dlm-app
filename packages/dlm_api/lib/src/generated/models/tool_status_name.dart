// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Which tool.
@JsonEnum()
enum ToolStatusName {
  @JsonValue('ffmpeg')
  ffmpeg('ffmpeg'),
  @JsonValue('yt-dlp')
  ytDlp('yt-dlp'),
  @JsonValue('browser')
  browser('browser'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ToolStatusName(this.json);

  factory ToolStatusName.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<ToolStatusName> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
