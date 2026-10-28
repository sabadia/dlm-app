// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// auto (default) answers whatever the server asks for, basic sends the login with the first request, digest answers a Digest challenge.
@JsonEnum()
enum CreateCredentialBodyScheme {
  @JsonValue('auto')
  auto('auto'),
  @JsonValue('basic')
  basic('basic'),
  @JsonValue('digest')
  digest('digest'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CreateCredentialBodyScheme(this.json);

  factory CreateCredentialBodyScheme.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<CreateCredentialBodyScheme> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
