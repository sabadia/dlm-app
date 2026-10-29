// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CaptureChecksumAlgorithm {
  @JsonValue('md5')
  md5('md5'),
  @JsonValue('sha1')
  sha1('sha1'),
  @JsonValue('sha256')
  sha256('sha256'),
  @JsonValue('blake3')
  blake3('blake3'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CaptureChecksumAlgorithm(this.json);

  factory CaptureChecksumAlgorithm.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<CaptureChecksumAlgorithm> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
