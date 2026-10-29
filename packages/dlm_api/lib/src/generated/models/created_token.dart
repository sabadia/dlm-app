// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'token.dart';

part 'created_token.g.dart';

@JsonSerializable()
class CreatedToken {
  const CreatedToken({required this.token, this.schema, this.info});

  factory CreatedToken.fromJson(Map<String, Object?> json) =>
      _$CreatedTokenFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final Token? info;

  /// The secret. It is shown only now: the daemon keeps a hash of a named token, and the primary token's file is the only other copy.
  final String token;

  Map<String, Object?> toJson() => _$CreatedTokenToJson(this);
}
