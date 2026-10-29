// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_credential_body_scheme.dart';

part 'create_credential_body.g.dart';

@JsonSerializable()
class CreateCredentialBody {
  const CreateCredentialBody({
    required this.host,
    required this.password,
    required this.username,
    this.schema,
    this.scheme,
  });

  factory CreateCredentialBody.fromJson(Map<String, Object?> json) =>
      _$CreateCredentialBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Host name the login is for: example.com (only that host) or *.example.com (its subdomains). No scheme, port or path.
  final String host;

  /// Password; stored encrypted and never returned.
  final String password;

  /// auto (default) answers whatever the server asks for, basic sends the login with the first request, digest answers a Digest challenge.
  final CreateCredentialBodyScheme? scheme;

  /// User name.
  final String username;

  Map<String, Object?> toJson() => _$CreateCredentialBodyToJson(this);
}
