// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'settings.dart';

part 'effective.g.dart';

@JsonSerializable()
class Effective {
  const Effective({required this.settings, required this.sources, this.schema});

  factory Effective.fromJson(Map<String, Object?> json) =>
      _$EffectiveFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final Settings settings;
  final Map<String, String> sources;

  Map<String, Object?> toJson() => _$EffectiveToJson(this);
}
