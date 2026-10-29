// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_requested_data.dart';
import 'pairing_requested_event_type.dart';
import 'stream_event.dart';

part 'pairing_requested_event.g.dart';

/// A browser extension asked to be paired and waits for the user to allow or deny it; compare the code with the one the extension shows.
@JsonSerializable()
class PairingRequestedEvent {
  const PairingRequestedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory PairingRequestedEvent.fromJson(Map<String, Object?> json) =>
      _$PairingRequestedEventFromJson(json);

  final PairingRequestedData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final PairingRequestedEventType type;

  Map<String, Object?> toJson() => _$PairingRequestedEventToJson(this);
}
