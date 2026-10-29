// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// The browser the extension runs in.
@JsonEnum()
enum PairingBodyBrowser {
  @JsonValue('chrome')
  chrome('chrome'),
  @JsonValue('chromium')
  chromium('chromium'),
  @JsonValue('edge')
  edge('edge'),
  @JsonValue('brave')
  brave('brave'),
  @JsonValue('opera')
  opera('opera'),
  @JsonValue('vivaldi')
  vivaldi('vivaldi'),
  @JsonValue('firefox')
  firefox('firefox'),
  @JsonValue('other')
  other('other'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const PairingBodyBrowser(this.json);

  factory PairingBodyBrowser.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<PairingBodyBrowser> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
