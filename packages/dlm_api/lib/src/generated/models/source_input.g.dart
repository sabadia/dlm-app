// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceInput _$SourceInputFromJson(Map<String, dynamic> json) => SourceInput(
  currentUrl: json['currentUrl'] as String,
  body: json['body'] as String?,
  cookieDomains: (json['cookieDomains'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  mediaHint: json['mediaHint'] as String?,
  method: json['method'] as String?,
  mirrors: (json['mirrors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  originalUrl: json['originalUrl'] as String?,
  pageUrl: json['pageUrl'] as String?,
  referrer: json['referrer'] as String?,
  resolverKind: json['resolverKind'] == null
      ? null
      : SourceInputResolverKind.fromJson(json['resolverKind'] as String),
  userAgent: json['userAgent'] as String?,
);

Map<String, dynamic> _$SourceInputToJson(SourceInput instance) =>
    <String, dynamic>{
      'body': instance.body,
      'cookieDomains': instance.cookieDomains,
      'currentUrl': instance.currentUrl,
      'headers': instance.headers,
      'mediaHint': instance.mediaHint,
      'method': instance.method,
      'mirrors': instance.mirrors,
      'originalUrl': instance.originalUrl,
      'pageUrl': instance.pageUrl,
      'referrer': instance.referrer,
      'resolverKind': _$SourceInputResolverKindEnumMap[instance.resolverKind],
      'userAgent': instance.userAgent,
    };

const _$SourceInputResolverKindEnumMap = {
  SourceInputResolverKind.direct: 'direct',
  SourceInputResolverKind.browser: 'browser',
  SourceInputResolverKind.ytdlp: 'ytdlp',
  SourceInputResolverKind.plugin: 'plugin',
  SourceInputResolverKind.$unknown: r'$unknown',
};
