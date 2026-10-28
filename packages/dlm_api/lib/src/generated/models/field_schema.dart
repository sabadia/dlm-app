// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'field_schema_type.dart';

part 'field_schema.g.dart';

@JsonSerializable()
class FieldSchema {
  const FieldSchema({
    required this.description,
    required this.group,
    required this.levels,
    required this.path,
    required this.type,
    this.enumValue,
    this.max,
    this.min,
    this.restartRequired,
    this.secret,
    this.unit,
  });

  factory FieldSchema.fromJson(Map<String, Object?> json) =>
      _$FieldSchemaFromJson(json);

  /// What the field does
  final String description;

  /// Accepted values of a closed set (of each element for arrays).
  /// The name has been replaced because it contains a keyword. Original name: `enum`.
  @JsonKey(name: 'enum')
  final List<String>? enumValue;

  /// Section the field belongs to
  final String group;

  /// Levels that may set the field
  final List<String>? levels;

  /// Largest accepted value
  final double? max;

  /// Smallest accepted value
  final double? min;

  /// Dotted JSON path of the field
  final String path;

  /// Changes only take effect after a daemon restart
  final bool? restartRequired;

  /// The value may hold credentials and must be hidden
  final bool? secret;

  /// Value type; a duration is a Go duration string such as 1m30s
  final FieldSchemaType type;

  /// Unit of numeric values, e.g. bytes/s or seconds
  final String? unit;

  Map<String, Object?> toJson() => _$FieldSchemaToJson(this);
}
