// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// admin may do everything; read may only read (GET), and not cookie exports, the token list or MCP; extension (a paired browser extension) may hand downloads to the daemon and follow them, and nothing else.
@JsonEnum()
enum WhoAmIScope {
  @JsonValue('admin')
  admin('admin'),
  @JsonValue('read')
  read('read'),

  /// The name has been replaced because it contains a keyword. Original name: `extension`.
  @JsonValue('extension')
  valueExtension('extension'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const WhoAmIScope(this.json);

  factory WhoAmIScope.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<WhoAmIScope> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
