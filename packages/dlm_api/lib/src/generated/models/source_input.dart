// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'source_input_resolver_kind.dart';

part 'source_input.g.dart';

@JsonSerializable()
class SourceInput {
  const SourceInput({
    required this.currentUrl,
    this.body,
    this.cookieDomains,
    this.headers,
    this.mediaHint,
    this.method,
    this.mirrors,
    this.originalUrl,
    this.pageUrl,
    this.referrer,
    this.resolverKind,
    this.userAgent,
  });

  factory SourceInput.fromJson(Map<String, Object?> json) =>
      _$SourceInputFromJson(json);

  /// Request body (base64).
  final String? body;

  /// Domains whose stored cookies apply.
  final List<String>? cookieDomains;

  /// Absolute URL to download.
  final String currentUrl;

  /// Request headers captured with the link.
  final Map<String, String>? headers;

  /// Manifest pattern or variant hint for streams.
  final String? mediaHint;

  /// HTTP method (default GET).
  final String? method;

  /// Other http(s) links to the same file. A ranged download spreads its connections over the mirrors that serve a file of the same size and supports ranges; the others are ignored.
  final List<String>? mirrors;

  /// URL the user started from (defaults to currentUrl); used for link refresh.
  final String? originalUrl;

  /// Web page the link was found on.
  final String? pageUrl;

  /// Referer header to send.
  final String? referrer;

  /// How the link was obtained (default direct).
  final SourceInputResolverKind? resolverKind;

  /// User agent captured with the link.
  final String? userAgent;

  Map<String, Object?> toJson() => _$SourceInputToJson(this);
}
