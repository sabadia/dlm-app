// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing.dart';

part 'pairing_list.g.dart';

@JsonSerializable()
class PairingList {
  const PairingList({required this.pairings, this.schema});

  factory PairingList.fromJson(Map<String, Object?> json) =>
      _$PairingListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The pairings waiting for an answer, oldest first.
  final List<Pairing>? pairings;

  Map<String, Object?> toJson() => _$PairingListToJson(this);
}
