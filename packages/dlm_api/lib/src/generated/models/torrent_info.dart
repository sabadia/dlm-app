// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'torrent_peer.dart';

part 'torrent_info.g.dart';

@JsonSerializable()
class TorrentInfo {
  const TorrentInfo({
    required this.downloaded,
    required this.knownPeers,
    required this.peerCount,
    required this.private,
    required this.ratio,
    required this.seeders,
    required this.seedingSeconds,
    required this.state,
    required this.uploaded,
    this.schema,
    this.infoHash,
    this.name,
    this.peers,
    this.trackers,
  });

  factory TorrentInfo.fromJson(Map<String, Object?> json) =>
      _$TorrentInfoFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final int downloaded;
  final String? infoHash;
  final int knownPeers;
  final String? name;
  final int peerCount;
  final List<TorrentPeer>? peers;
  final bool private;
  final double ratio;
  final int seeders;
  final int seedingSeconds;
  final String state;
  final List<String>? trackers;
  final int uploaded;

  Map<String, Object?> toJson() => _$TorrentInfoToJson(this);
}
