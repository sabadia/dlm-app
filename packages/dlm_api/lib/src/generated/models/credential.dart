// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'credential.g.dart';

@JsonSerializable()
class Credential {
  const Credential({
    required this.createdAt,
    required this.host,
    required this.id,
    required this.scheme,
    required this.updatedAt,
    required this.username,
    this.schema,
  });

  factory Credential.fromJson(Map<String, Object?> json) =>
      _$CredentialFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final DateTime createdAt;
  final String host;
  final String id;
  final String scheme;
  final DateTime updatedAt;
  final String username;

  Map<String, Object?> toJson() => _$CredentialToJson(this);
}
