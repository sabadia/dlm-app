// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  const Token({
    required this.createdAt,
    required this.id,
    required this.name,
    required this.scope,
    this.lastUsedAt,
  });

  factory Token.fromJson(Map<String, Object?> json) => _$TokenFromJson(json);

  final DateTime createdAt;
  final String id;
  final DateTime? lastUsedAt;
  final String name;
  final String scope;

  Map<String, Object?> toJson() => _$TokenToJson(this);
}
