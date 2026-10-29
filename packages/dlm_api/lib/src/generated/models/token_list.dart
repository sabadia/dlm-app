// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'token.dart';

part 'token_list.g.dart';

@JsonSerializable()
class TokenList {
  const TokenList({required this.tokens, this.schema});

  factory TokenList.fromJson(Map<String, Object?> json) =>
      _$TokenListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The named tokens, oldest first. The primary token is not listed.
  final List<Token>? tokens;

  Map<String, Object?> toJson() => _$TokenListToJson(this);
}
