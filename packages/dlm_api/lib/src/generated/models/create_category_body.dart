// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_category_body.g.dart';

@JsonSerializable()
class CreateCategoryBody {
  const CreateCategoryBody({
    required this.dir,
    required this.name,
    this.schema,
    this.extensions,
    this.mimeTypes,
  });

  factory CreateCategoryBody.fromJson(Map<String, Object?> json) =>
      _$CreateCategoryBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Directory of the category's downloads: absolute, or relative to the download directory.
  final String dir;

  /// File extensions without the dot, such as mp4 or tar.gz.
  final List<String>? extensions;

  /// MIME types such as application/pdf, or families such as video/*.
  final List<String>? mimeTypes;

  /// Unique (case-insensitive) category name.
  final String name;

  Map<String, Object?> toJson() => _$CreateCategoryBodyToJson(this);
}
