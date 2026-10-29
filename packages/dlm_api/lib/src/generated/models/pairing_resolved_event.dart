// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_resolved_data.dart';
import 'pairing_resolved_event_type.dart';
import 'stream_event.dart';

part 'pairing_resolved_event.g.dart';

/// A pairing was allowed, denied or ran out of time; close the prompt.
@JsonSerializable()
class PairingResolvedEvent {
  const PairingResolvedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory PairingResolvedEvent.fromJson(Map<String, Object?> json) =>
      _$PairingResolvedEventFromJson(json);

  final PairingResolvedData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final PairingResolvedEventType type;

  Map<String, Object?> toJson() => _$PairingResolvedEventToJson(this);
}
