// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'problem.dart';
import 'resolve_result.dart';

part 'resolve_item.g.dart';

@JsonSerializable()
class ResolveItem {
  const ResolveItem({required this.ok, this.error, this.result});

  factory ResolveItem.fromJson(Map<String, Object?> json) =>
      _$ResolveItemFromJson(json);

  /// Why the item failed (RFC 9457 problem with a code).
  final Problem? error;

  /// Whether the probe succeeded.
  final bool ok;

  /// What the source would download (as resolve-task answers), with duplicateOf when another task already has it.
  final ResolveResult? result;

  Map<String, Object?> toJson() => _$ResolveItemToJson(this);
}
