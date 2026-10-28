// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'fingerprint.g.dart';

@JsonSerializable()
class Fingerprint {
  const Fingerprint({
    required this.size,
    this.contentType,
    this.etag,
    this.filename,
    this.lastModified,
  });

  factory Fingerprint.fromJson(Map<String, Object?> json) =>
      _$FingerprintFromJson(json);

  final String? contentType;
  final String? etag;
  final String? filename;
  final DateTime? lastModified;
  final int size;

  Map<String, Object?> toJson() => _$FingerprintToJson(this);
}
