// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_category_body.g.dart';

@JsonSerializable()
class UpdateCategoryBody {
  const UpdateCategoryBody({
    this.schema,
    this.dir,
    this.extensions,
    this.mimeTypes,
    this.name,
    this.position,
  });

  factory UpdateCategoryBody.fromJson(Map<String, Object?> json) =>
      _$UpdateCategoryBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// New directory.
  final String? dir;

  /// New extensions.
  final List<String>? extensions;

  /// New MIME types.
  final List<String>? mimeTypes;

  /// New name.
  final String? name;

  /// New place in the order (0 is tried first).
  final int? position;

  Map<String, Object?> toJson() => _$UpdateCategoryBodyToJson(this);
}
