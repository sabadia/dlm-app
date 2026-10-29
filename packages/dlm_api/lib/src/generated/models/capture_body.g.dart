// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptureBody _$CaptureBodyFromJson(Map<String, dynamic> json) => CaptureBody(
  schema: json[r'$schema'] as String?,
  allowDuplicate: json['allowDuplicate'] as bool?,
  body: json['body'] as String?,
  checksum: json['checksum'] == null
      ? null
      : CaptureChecksum.fromJson(json['checksum'] as Map<String, dynamic>),
  cookieScope: json['cookieScope'] == null
      ? null
      : CaptureBodyCookieScope.fromJson(json['cookieScope'] as String),
  cookies: (json['cookies'] as List<dynamic>?)
      ?.map((e) => CaptureCookie.fromJson(e as Map<String, dynamic>))
      .toList(),
  dir: json['dir'] as String?,
  filename: json['filename'] as String?,
  finalUrl: json['finalUrl'] as String?,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  labels: (json['labels'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  mediaCandidates: (json['mediaCandidates'] as List<dynamic>?)
      ?.map((e) => MediaCandidateBody.fromJson(e as Map<String, dynamic>))
      .toList(),
  method: json['method'] as String?,
  mime: json['mime'] as String?,
  mirrors: (json['mirrors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  name: json['name'] as String?,
  pageUrl: json['pageUrl'] as String?,
  paused: json['paused'] as bool?,
  priority: json['priority'] == null
      ? null
      : CaptureBodyPriority.fromJson(json['priority'] as String),
  queueId: json['queueId'] as String?,
  referrer: json['referrer'] as String?,
  resolverKind: json['resolverKind'] == null
      ? null
      : CaptureBodyResolverKind.fromJson(json['resolverKind'] as String),
  settings: json['settings'] == null
      ? null
      : Settings.fromJson(json['settings'] as Map<String, dynamic>),
  size: (json['size'] as num?)?.toInt(),
  url: json['url'] as String?,
  userAgent: json['userAgent'] as String?,
);

Map<String, dynamic> _$CaptureBodyToJson(CaptureBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'allowDuplicate': instance.allowDuplicate,
      'body': instance.body,
      'checksum': instance.checksum,
      'cookieScope': _$CaptureBodyCookieScopeEnumMap[instance.cookieScope],
      'cookies': instance.cookies,
      'dir': instance.dir,
      'filename': instance.filename,
      'finalUrl': instance.finalUrl,
      'headers': instance.headers,
      'labels': instance.labels,
      'mediaCandidates': instance.mediaCandidates,
      'method': instance.method,
      'mime': instance.mime,
      'mirrors': instance.mirrors,
      'name': instance.name,
      'pageUrl': instance.pageUrl,
      'paused': instance.paused,
      'priority': _$CaptureBodyPriorityEnumMap[instance.priority],
      'queueId': instance.queueId,
      'referrer': instance.referrer,
      'resolverKind': _$CaptureBodyResolverKindEnumMap[instance.resolverKind],
      'settings': instance.settings,
      'size': instance.size,
      'url': instance.url,
      'userAgent': instance.userAgent,
    };

const _$CaptureBodyCookieScopeEnumMap = {
  CaptureBodyCookieScope.task: 'task',
  CaptureBodyCookieScope.store: 'store',
  CaptureBodyCookieScope.$unknown: r'$unknown',
};

const _$CaptureBodyPriorityEnumMap = {
  CaptureBodyPriority.low: 'low',
  CaptureBodyPriority.normal: 'normal',
  CaptureBodyPriority.high: 'high',
  CaptureBodyPriority.$unknown: r'$unknown',
};

const _$CaptureBodyResolverKindEnumMap = {
  CaptureBodyResolverKind.direct: 'direct',
  CaptureBodyResolverKind.ytdlp: 'ytdlp',
  CaptureBodyResolverKind.browser: 'browser',
  CaptureBodyResolverKind.$unknown: r'$unknown',
};
