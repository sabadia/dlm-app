// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  const Category({
    required this.dir,
    required this.id,
    required this.name,
    required this.position,
    this.schema,
    this.extensions,
    this.mimeTypes,
  });

  factory Category.fromJson(Map<String, Object?> json) =>
      _$CategoryFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final String dir;
  final List<String>? extensions;
  final String id;
  final List<String>? mimeTypes;
  final String name;
  final int position;

  Map<String, Object?> toJson() => _$CategoryToJson(this);
}
