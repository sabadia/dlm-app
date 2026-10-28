// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'position_body.g.dart';

@JsonSerializable()
class PositionBody {
  const PositionBody({required this.position, this.schema});

  factory PositionBody.fromJson(Map<String, Object?> json) =>
      _$PositionBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// 0-based target index (clamped to the last index).
  final int position;

  Map<String, Object?> toJson() => _$PositionBodyToJson(this);
}
