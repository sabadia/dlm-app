// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_source_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTaskSourceBody _$UpdateTaskSourceBodyFromJson(
  Map<String, dynamic> json,
) => UpdateTaskSourceBody(
  currentUrl: json['currentUrl'] as String,
  schema: json[r'$schema'] as String?,
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
  onMismatch: json['onMismatch'] == null
      ? null
      : UpdateTaskSourceBodyOnMismatch.fromJson(json['onMismatch'] as String),
  originalUrl: json['originalUrl'] as String?,
  pageUrl: json['pageUrl'] as String?,
  referrer: json['referrer'] as String?,
  resolverKind: json['resolverKind'] == null
      ? null
      : UpdateTaskSourceBodyResolverKind.fromJson(
          json['resolverKind'] as String,
        ),
  userAgent: json['userAgent'] as String?,
);

Map<String, dynamic> _$UpdateTaskSourceBodyToJson(
  UpdateTaskSourceBody instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'body': instance.body,
  'cookieDomains': instance.cookieDomains,
  'currentUrl': instance.currentUrl,
  'headers': instance.headers,
  'mediaHint': instance.mediaHint,
  'method': instance.method,
  'mirrors': instance.mirrors,
  'onMismatch': _$UpdateTaskSourceBodyOnMismatchEnumMap[instance.onMismatch],
  'originalUrl': instance.originalUrl,
  'pageUrl': instance.pageUrl,
  'referrer': instance.referrer,
  'resolverKind':
      _$UpdateTaskSourceBodyResolverKindEnumMap[instance.resolverKind],
  'userAgent': instance.userAgent,
};

const _$UpdateTaskSourceBodyOnMismatchEnumMap = {
  UpdateTaskSourceBodyOnMismatch.restart: 'restart',
  UpdateTaskSourceBodyOnMismatch.fail: 'fail',
  UpdateTaskSourceBodyOnMismatch.$unknown: r'$unknown',
};

const _$UpdateTaskSourceBodyResolverKindEnumMap = {
  UpdateTaskSourceBodyResolverKind.direct: 'direct',
  UpdateTaskSourceBodyResolverKind.browser: 'browser',
  UpdateTaskSourceBodyResolverKind.ytdlp: 'ytdlp',
  UpdateTaskSourceBodyResolverKind.plugin: 'plugin',
  UpdateTaskSourceBodyResolverKind.$unknown: r'$unknown',
};
