// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'checksum.g.dart';

@JsonSerializable()
class Checksum {
  const Checksum({required this.algorithm, required this.expected});

  factory Checksum.fromJson(Map<String, Object?> json) =>
      _$ChecksumFromJson(json);

  final String algorithm;
  final String expected;

  Map<String, Object?> toJson() => _$ChecksumToJson(this);
}
