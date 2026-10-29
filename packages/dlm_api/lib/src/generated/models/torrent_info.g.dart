// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TorrentInfo _$TorrentInfoFromJson(Map<String, dynamic> json) => TorrentInfo(
  downloaded: (json['downloaded'] as num).toInt(),
  knownPeers: (json['knownPeers'] as num).toInt(),
  peerCount: (json['peerCount'] as num).toInt(),
  private: json['private'] as bool,
  ratio: (json['ratio'] as num).toDouble(),
  seeders: (json['seeders'] as num).toInt(),
  seedingSeconds: (json['seedingSeconds'] as num).toInt(),
  state: json['state'] as String,
  uploaded: (json['uploaded'] as num).toInt(),
  schema: json[r'$schema'] as String?,
  infoHash: json['infoHash'] as String?,
  name: json['name'] as String?,
  peers: (json['peers'] as List<dynamic>?)
      ?.map((e) => TorrentPeer.fromJson(e as Map<String, dynamic>))
      .toList(),
  trackers: (json['trackers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TorrentInfoToJson(TorrentInfo instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'downloaded': instance.downloaded,
      'infoHash': instance.infoHash,
      'knownPeers': instance.knownPeers,
      'name': instance.name,
      'peerCount': instance.peerCount,
      'peers': instance.peers,
      'private': instance.private,
      'ratio': instance.ratio,
      'seeders': instance.seeders,
      'seedingSeconds': instance.seedingSeconds,
      'state': instance.state,
      'trackers': instance.trackers,
      'uploaded': instance.uploaded,
    };
