// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_credential_body_scheme.dart';

part 'update_credential_body.g.dart';

@JsonSerializable()
class UpdateCredentialBody {
  const UpdateCredentialBody({
    this.schema,
    this.host,
    this.password,
    this.scheme,
    this.username,
  });

  factory UpdateCredentialBody.fromJson(Map<String, Object?> json) =>
      _$UpdateCredentialBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// New host.
  final String? host;

  /// New password.
  final String? password;

  /// New scheme.
  final UpdateCredentialBodyScheme? scheme;

  /// New user name.
  final String? username;

  Map<String, Object?> toJson() => _$UpdateCredentialBodyToJson(this);
}
