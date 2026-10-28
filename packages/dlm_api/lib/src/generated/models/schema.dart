// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'field_schema.dart';

part 'schema.g.dart';

@JsonSerializable()
class Schema {
  const Schema({required this.fields, this.schema});

  factory Schema.fromJson(Map<String, Object?> json) => _$SchemaFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// One entry per settings field, in display order
  final List<FieldSchema>? fields;

  Map<String, Object?> toJson() => _$SchemaToJson(this);
}
