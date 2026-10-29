// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  schema: json[r'$schema'] as String?,
  autoCategorize: json['autoCategorize'] as bool?,
  browserUsage: json['browserUsage'] as String?,
  checksum: json['checksum'] == null
      ? null
      : Checksum.fromJson(json['checksum'] as Map<String, dynamic>),
  downloadDir: json['downloadDir'] as String?,
  fileExistsPolicy: json['fileExistsPolicy'] as String?,
  filenameTemplate: json['filenameTemplate'] as String?,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  maxActiveDownloadsTotal: (json['maxActiveDownloadsTotal'] as num?)?.toInt(),
  maxConcurrentDownloads: (json['maxConcurrentDownloads'] as num?)?.toInt(),
  maxConnections: (json['maxConnections'] as num?)?.toInt(),
  onQueueComplete: json['onQueueComplete'] == null
      ? null
      : OnQueueComplete.fromJson(
          json['onQueueComplete'] as Map<String, dynamic>,
        ),
  postActions: (json['postActions'] as List<dynamic>?)
      ?.map((e) => PostAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  proxy: json['proxy'] == null
      ? null
      : Proxy.fromJson(json['proxy'] as Map<String, dynamic>),
  proxyRules: (json['proxyRules'] as List<dynamic>?)
      ?.map((e) => ProxyRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  quota: json['quota'] == null
      ? null
      : Quota.fromJson(json['quota'] as Map<String, dynamic>),
  refresh: json['refresh'] == null
      ? null
      : RefreshSettings.fromJson(json['refresh'] as Map<String, dynamic>),
  retentionDays: (json['retentionDays'] as num?)?.toInt(),
  retry: json['retry'] == null
      ? null
      : RetrySettings.fromJson(json['retry'] as Map<String, dynamic>),
  schedule: json['schedule'] == null
      ? null
      : Schedule.fromJson(json['schedule'] as Map<String, dynamic>),
  speedLimit: (json['speedLimit'] as num?)?.toInt(),
  speedProfiles: (json['speedProfiles'] as List<dynamic>?)
      ?.map((e) => SpeedProfile.fromJson(e as Map<String, dynamic>))
      .toList(),
  tlsVerify: json['tlsVerify'] as bool?,
  torrent: json['torrent'] == null
      ? null
      : TorrentSettings.fromJson(json['torrent'] as Map<String, dynamic>),
  userAgent: json['userAgent'] as String?,
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'autoCategorize': instance.autoCategorize,
  'browserUsage': instance.browserUsage,
  'checksum': instance.checksum,
  'downloadDir': instance.downloadDir,
  'fileExistsPolicy': instance.fileExistsPolicy,
  'filenameTemplate': instance.filenameTemplate,
  'headers': instance.headers,
  'maxActiveDownloadsTotal': instance.maxActiveDownloadsTotal,
  'maxConcurrentDownloads': instance.maxConcurrentDownloads,
  'maxConnections': instance.maxConnections,
  'onQueueComplete': instance.onQueueComplete,
  'postActions': instance.postActions,
  'proxy': instance.proxy,
  'proxyRules': instance.proxyRules,
  'quota': instance.quota,
  'refresh': instance.refresh,
  'retentionDays': instance.retentionDays,
  'retry': instance.retry,
  'schedule': instance.schedule,
  'speedLimit': instance.speedLimit,
  'speedProfiles': instance.speedProfiles,
  'tlsVerify': instance.tlsVerify,
  'torrent': instance.torrent,
  'userAgent': instance.userAgent,
};
