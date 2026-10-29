// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'torrent_settings.g.dart';

@JsonSerializable()
class TorrentSettings {
  const TorrentSettings({
    this.seedKeep,
    this.seedRatio,
    this.seedTime,
    this.trackers,
  });

  factory TorrentSettings.fromJson(Map<String, Object?> json) =>
      _$TorrentSettingsFromJson(json);

  final bool? seedKeep;
  final double? seedRatio;
  final String? seedTime;
  final List<String>? trackers;

  Map<String, Object?> toJson() => _$TorrentSettingsToJson(this);
}
