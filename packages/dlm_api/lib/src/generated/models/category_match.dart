// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category.dart';

part 'category_match.g.dart';

@JsonSerializable()
class CategoryMatch {
  const CategoryMatch({this.schema, this.category});

  factory CategoryMatch.fromJson(Map<String, Object?> json) =>
      _$CategoryMatchFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The first matching category; absent when none matches.
  final Category? category;

  Map<String, Object?> toJson() => _$CategoryMatchToJson(this);
}
