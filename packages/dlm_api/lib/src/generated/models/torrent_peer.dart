// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'torrent_peer.g.dart';

@JsonSerializable()
class TorrentPeer {
  const TorrentPeer({
    required this.address,
    required this.downloadRate,
    this.client,
  });

  factory TorrentPeer.fromJson(Map<String, Object?> json) =>
      _$TorrentPeerFromJson(json);

  final String address;
  final String? client;
  final int downloadRate;

  Map<String, Object?> toJson() => _$TorrentPeerToJson(this);
}
