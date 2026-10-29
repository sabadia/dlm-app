// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent_peer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TorrentPeer _$TorrentPeerFromJson(Map<String, dynamic> json) => TorrentPeer(
  address: json['address'] as String,
  downloadRate: (json['downloadRate'] as num).toInt(),
  client: json['client'] as String?,
);

Map<String, dynamic> _$TorrentPeerToJson(TorrentPeer instance) =>
    <String, dynamic>{
      'address': instance.address,
      'client': instance.client,
      'downloadRate': instance.downloadRate,
    };
