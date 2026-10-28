// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'credential.dart';

part 'credential_list.g.dart';

@JsonSerializable()
class CredentialList {
  const CredentialList({required this.credentials, this.schema});

  factory CredentialList.fromJson(Map<String, Object?> json) =>
      _$CredentialListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Every stored login, ordered by host.
  final List<Credential>? credentials;

  Map<String, Object?> toJson() => _$CredentialListToJson(this);
}
