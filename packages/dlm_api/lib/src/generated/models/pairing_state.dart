// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'pairing_state.g.dart';

@JsonSerializable()
class PairingState {
  const PairingState({
    required this.browser,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.id,
    required this.name,
    required this.status,
    this.schema,
    this.clientId,
    this.clientVersion,
    this.token,
    this.tokenId,
  });

  factory PairingState.fromJson(Map<String, Object?> json) =>
      _$PairingStateFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final String browser;
  final String? clientId;
  final String? clientVersion;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String id;
  final String name;
  final String status;

  /// The token of an approved pairing. Present once: the first time the pairing is read after it was allowed.
  final String? token;
  final String? tokenId;

  Map<String, Object?> toJson() => _$PairingStateToJson(this);
}
