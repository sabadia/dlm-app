// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'fs_free.g.dart';

@JsonSerializable()
class FsFree {
  const FsFree({required this.freeBytes, required this.path, this.schema});

  factory FsFree.fromJson(Map<String, Object?> json) => _$FsFreeFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Bytes available to the daemon in the directory's file system.
  final int freeBytes;
  final String path;

  Map<String, Object?> toJson() => _$FsFreeToJson(this);
}
