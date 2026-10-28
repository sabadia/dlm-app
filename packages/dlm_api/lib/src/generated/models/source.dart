// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'fingerprint.dart';

part 'source.g.dart';

@JsonSerializable()
class Source {
  const Source({
    required this.currentUrl,
    required this.fingerprint,
    this.body,
    this.cookieDomains,
    this.headers,
    this.mediaHint,
    this.method,
    this.mirrors,
    this.originalUrl,
    this.pageUrl,
    this.redirectUrl,
    this.referrer,
    this.resolverKind,
    this.userAgent,
  });

  factory Source.fromJson(Map<String, Object?> json) => _$SourceFromJson(json);

  final String? body;
  final List<String>? cookieDomains;
  final String currentUrl;
  final Fingerprint fingerprint;
  final Map<String, String>? headers;
  final String? mediaHint;
  final String? method;
  final List<String>? mirrors;
  final String? originalUrl;
  final String? pageUrl;
  final String? redirectUrl;
  final String? referrer;
  final String? resolverKind;
  final String? userAgent;

  Map<String, Object?> toJson() => _$SourceToJson(this);
}
