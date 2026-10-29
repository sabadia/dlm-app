// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'duplicate_hint.dart';
import 'resource.dart';
import 'source.dart';

part 'resolve_result.g.dart';

@JsonSerializable()
class ResolveResult {
  const ResolveResult({
    required this.engine,
    required this.expiresAt,
    required this.name,
    required this.resolveId,
    required this.resource,
    required this.source,
    this.schema,
    this.duplicateOf,
  });

  factory ResolveResult.fromJson(Map<String, Object?> json) =>
      _$ResolveResultFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final DuplicateHint? duplicateOf;
  final String engine;
  final DateTime expiresAt;
  final String name;
  final String resolveId;
  final Resource resource;
  final Source source;

  Map<String, Object?> toJson() => _$ResolveResultToJson(this);
}
