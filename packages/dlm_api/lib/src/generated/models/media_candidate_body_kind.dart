// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Resource kind; unset counts as file.
@JsonEnum()
enum MediaCandidateBodyKind {
  @JsonValue('hls')
  hls('hls'),
  @JsonValue('dash')
  dash('dash'),
  @JsonValue('video')
  video('video'),
  @JsonValue('audio')
  audio('audio'),
  @JsonValue('file')
  file('file'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const MediaCandidateBodyKind(this.json);

  factory MediaCandidateBodyKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<MediaCandidateBodyKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
