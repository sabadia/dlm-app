// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'who_am_i_scope.dart';

part 'who_am_i.g.dart';

@JsonSerializable()
class WhoAmI {
  const WhoAmI({
    required this.local,
    required this.name,
    required this.primary,
    required this.scope,
    required this.tls,
    this.schema,
  });

  factory WhoAmI.fromJson(Map<String, Object?> json) => _$WhoAmIFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Whether the request came from the machine the daemon runs on.
  final bool local;

  /// The token's name; primary for the token in the daemon's token file.
  final String name;
  final bool primary;

  /// admin may do everything; read may only read (GET), and not cookie exports, the token list or MCP.
  final WhoAmIScope scope;

  /// Whether the connection is encrypted.
  final bool tls;

  Map<String, Object?> toJson() => _$WhoAmIToJson(this);
}
