// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TorrentSettings _$TorrentSettingsFromJson(Map<String, dynamic> json) =>
    TorrentSettings(
      seedKeep: json['seedKeep'] as bool?,
      seedRatio: json['seedRatio'],
      seedTime: json['seedTime'] as String?,
      trackers: json['trackers'],
    );

Map<String, dynamic> _$TorrentSettingsToJson(TorrentSettings instance) =>
    <String, dynamic>{
      'seedKeep': instance.seedKeep,
      'seedRatio': instance.seedRatio,
      'seedTime': instance.seedTime,
      'trackers': instance.trackers,
    };
