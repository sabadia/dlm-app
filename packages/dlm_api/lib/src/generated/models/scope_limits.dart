// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'profile_view.dart';
import 'quota_view.dart';

part 'scope_limits.g.dart';

@JsonSerializable()
class ScopeLimits {
  const ScopeLimits({
    required this.configuredSpeedLimit,
    required this.speedLimit,
    this.activeProfile,
    this.name,
    this.queueId,
    this.quota,
  });

  factory ScopeLimits.fromJson(Map<String, Object?> json) =>
      _$ScopeLimitsFromJson(json);

  final ProfileView? activeProfile;
  final int configuredSpeedLimit;
  final String? name;
  final String? queueId;
  final QuotaView? quota;
  final int speedLimit;

  Map<String, Object?> toJson() => _$ScopeLimitsToJson(this);
}
