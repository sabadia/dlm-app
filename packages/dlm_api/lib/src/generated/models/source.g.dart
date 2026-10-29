// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Source _$SourceFromJson(Map<String, dynamic> json) => Source(
  currentUrl: json['currentUrl'] as String,
  fingerprint: Fingerprint.fromJson(
    json['fingerprint'] as Map<String, dynamic>,
  ),
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
  redirectUrl: json['redirectUrl'] as String?,
  referrer: json['referrer'] as String?,
  resolverKind: json['resolverKind'] as String?,
  streamKind: json['streamKind'] as String?,
  userAgent: json['userAgent'] as String?,
);

Map<String, dynamic> _$SourceToJson(Source instance) => <String, dynamic>{
  'body': instance.body,
  'cookieDomains': instance.cookieDomains,
  'currentUrl': instance.currentUrl,
  'fingerprint': instance.fingerprint,
  'headers': instance.headers,
  'mediaHint': instance.mediaHint,
  'method': instance.method,
  'mirrors': instance.mirrors,
  'originalUrl': instance.originalUrl,
  'pageUrl': instance.pageUrl,
  'redirectUrl': instance.redirectUrl,
  'referrer': instance.referrer,
  'resolverKind': instance.resolverKind,
  'streamKind': instance.streamKind,
  'userAgent': instance.userAgent,
};
