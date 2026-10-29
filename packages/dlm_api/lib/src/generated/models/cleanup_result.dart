// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'cleanup_result.g.dart';

@JsonSerializable()
class CleanupResult {
  const CleanupResult({
    required this.bytes,
    required this.deleted,
    required this.failed,
    required this.matched,
    this.schema,
  });

  factory CleanupResult.fromJson(Map<String, Object?> json) =>
      _$CleanupResultFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final int bytes;
  final int deleted;
  final int failed;
  final int matched;

  Map<String, Object?> toJson() => _$CleanupResultToJson(this);
}
