// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// How the link is turned into a download: direct (a file, the default), ytdlp (a video or audio page yt-dlp can extract) or browser (a page that needs the headless browser).
@JsonEnum()
enum CaptureBodyResolverKind {
  @JsonValue('direct')
  direct('direct'),
  @JsonValue('ytdlp')
  ytdlp('ytdlp'),
  @JsonValue('browser')
  browser('browser'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CaptureBodyResolverKind(this.json);

  factory CaptureBodyResolverKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<CaptureBodyResolverKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
