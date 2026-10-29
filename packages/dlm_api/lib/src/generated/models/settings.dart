// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'checksum.dart';
import 'on_queue_complete.dart';
import 'post_action.dart';
import 'proxy.dart';
import 'proxy_rule.dart';
import 'quota.dart';
import 'refresh_settings.dart';
import 'retry_settings.dart';
import 'schedule.dart';
import 'speed_profile.dart';
import 'torrent_settings.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  const Settings({
    this.schema,
    this.autoCategorize,
    this.browserUsage,
    this.checksum,
    this.downloadDir,
    this.fileExistsPolicy,
    this.filenameTemplate,
    this.headers,
    this.maxActiveDownloadsTotal,
    this.maxConcurrentDownloads,
    this.maxConnections,
    this.onQueueComplete,
    this.postActions,
    this.proxy,
    this.proxyRules,
    this.quota,
    this.refresh,
    this.retry,
    this.schedule,
    this.speedLimit,
    this.speedProfiles,
    this.tlsVerify,
    this.torrent,
    this.userAgent,
  });

  factory Settings.fromJson(Map<String, Object?> json) =>
      _$SettingsFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final bool? autoCategorize;
  final String? browserUsage;
  final Checksum? checksum;
  final String? downloadDir;
  final String? fileExistsPolicy;
  final String? filenameTemplate;
  final Map<String, String>? headers;
  final int? maxActiveDownloadsTotal;
  final int? maxConcurrentDownloads;
  final int? maxConnections;
  final OnQueueComplete? onQueueComplete;
  final List<PostAction>? postActions;
  final Proxy? proxy;
  final List<ProxyRule>? proxyRules;
  final Quota? quota;
  final RefreshSettings? refresh;
  final RetrySettings? retry;
  final Schedule? schedule;
  final int? speedLimit;
  final List<SpeedProfile>? speedProfiles;
  final bool? tlsVerify;
  final TorrentSettings? torrent;
  final String? userAgent;

  Map<String, Object?> toJson() => _$SettingsToJson(this);
}
