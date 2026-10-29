// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_body_browser.dart';

part 'pairing_body.g.dart';

@JsonSerializable()
class PairingBody {
  const PairingBody({
    this.schema,
    this.browser,
    this.clientId,
    this.name,
    this.version,
  });

  factory PairingBody.fromJson(Map<String, Object?> json) =>
      _$PairingBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The browser the extension runs in.
  final PairingBodyBrowser? browser;

  /// The extension's id (Chrome) or add-on id (Firefox).
  final String? clientId;

  /// What the client calls itself, shown to the user and used to name the token. Default: the browser's name and "extension".
  final String? name;

  /// The extension's version.
  final String? version;

  Map<String, Object?> toJson() => _$PairingBodyToJson(this);
}
