// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'problem.dart';
import 'task.dart';

part 'batch_item.g.dart';

@JsonSerializable()
class BatchItem {
  const BatchItem({required this.ok, this.error, this.id, this.task, this.url});

  factory BatchItem.fromJson(Map<String, Object?> json) =>
      _$BatchItemFromJson(json);

  /// Why the item failed (RFC 9457 problem with a code).
  final Problem? error;

  /// Task ID (the requested one, or the created task's ID).
  final String? id;

  /// Whether the item succeeded.
  final bool ok;

  /// The task's state after the operation (for delete: its last state).
  final Task? task;

  /// The link of an imported entry (import-tasks), so results can be matched to the list after patterns were expanded.
  final String? url;

  Map<String, Object?> toJson() => _$BatchItemToJson(this);
}
