// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Says the link is an HLS or DASH manifest although its path does not end in .m3u8 or .mpd.
@JsonEnum()
enum UpdateTaskSourceBodyStreamKind {
  @JsonValue('hls')
  hls('hls'),
  @JsonValue('dash')
  dash('dash'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const UpdateTaskSourceBodyStreamKind(this.json);

  factory UpdateTaskSourceBodyStreamKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<UpdateTaskSourceBodyStreamKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
