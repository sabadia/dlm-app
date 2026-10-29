// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Value type; a duration is a Go duration string such as 1m30s
@JsonEnum()
enum FieldSchemaType {
  @JsonValue('boolean')
  boolean('boolean'),
  @JsonValue('integer')
  integer('integer'),
  @JsonValue('number')
  number('number'),
  @JsonValue('string')
  string('string'),
  @JsonValue('duration')
  duration('duration'),
  @JsonValue('array')
  array('array'),
  @JsonValue('object')
  object('object'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const FieldSchemaType(this.json);

  factory FieldSchemaType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<FieldSchemaType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
