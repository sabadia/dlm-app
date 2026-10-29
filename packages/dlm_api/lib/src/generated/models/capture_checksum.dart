// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'capture_checksum_algorithm.dart';

part 'capture_checksum.g.dart';

@JsonSerializable()
class CaptureChecksum {
  const CaptureChecksum({required this.algorithm, required this.expected});

  factory CaptureChecksum.fromJson(Map<String, Object?> json) =>
      _$CaptureChecksumFromJson(json);

  final CaptureChecksumAlgorithm algorithm;

  /// The hash, hex encoded.
  final String expected;

  Map<String, Object?> toJson() => _$CaptureChecksumToJson(this);
}
