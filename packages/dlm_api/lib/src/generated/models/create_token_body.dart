// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_token_body_scope.dart';

part 'create_token_body.g.dart';

@JsonSerializable()
class CreateTokenBody {
  const CreateTokenBody({required this.name, required this.scope, this.schema});

  factory CreateTokenBody.fromJson(Map<String, Object?> json) =>
      _$CreateTokenBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// A name to recognise the token by (unique, ignoring case).
  final String name;

  /// admin may do everything; read may only read.
  final CreateTokenBodyScope scope;

  Map<String, Object?> toJson() => _$CreateTokenBodyToJson(this);
}
