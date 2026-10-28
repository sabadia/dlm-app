// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolStatus _$ToolStatusFromJson(Map<String, dynamic> json) => ToolStatus(
  autoDownload: json['autoDownload'] as bool,
  available: json['available'] as bool,
  name: ToolStatusName.fromJson(json['name'] as String),
  error: json['error'] as String?,
  path: json['path'] as String?,
  source: json['source'] == null
      ? null
      : ToolStatusSource.fromJson(json['source'] as String),
  version: json['version'] as String?,
);

Map<String, dynamic> _$ToolStatusToJson(ToolStatus instance) =>
    <String, dynamic>{
      'autoDownload': instance.autoDownload,
      'available': instance.available,
      'error': instance.error,
      'name': _$ToolStatusNameEnumMap[instance.name]!,
      'path': instance.path,
      'source': _$ToolStatusSourceEnumMap[instance.source],
      'version': instance.version,
    };

const _$ToolStatusNameEnumMap = {
  ToolStatusName.ffmpeg: 'ffmpeg',
  ToolStatusName.ytDlp: 'yt-dlp',
  ToolStatusName.browser: 'browser',
  ToolStatusName.$unknown: r'$unknown',
};

const _$ToolStatusSourceEnumMap = {
  ToolStatusSource.configured: 'configured',
  ToolStatusSource.path: 'path',
  ToolStatusSource.cache: 'cache',
  ToolStatusSource.download: 'download',
  ToolStatusSource.$unknown: r'$unknown',
};
