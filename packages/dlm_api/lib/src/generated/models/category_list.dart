// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category.dart';

part 'category_list.g.dart';

@JsonSerializable()
class CategoryList {
  const CategoryList({required this.categories, this.schema});

  factory CategoryList.fromJson(Map<String, Object?> json) =>
      _$CategoryListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Every category, in the order they are tried.
  final List<Category>? categories;

  Map<String, Object?> toJson() => _$CategoryListToJson(this);
}
