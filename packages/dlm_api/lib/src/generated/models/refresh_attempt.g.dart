// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_attempt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshAttempt _$RefreshAttemptFromJson(Map<String, dynamic> json) =>
    RefreshAttempt(
      cause: json['cause'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      downloaded: (json['downloaded'] as num).toInt(),
      id: json['id'] as String,
      outcome: json['outcome'] as String,
      strategy: json['strategy'] as String,
      taskId: json['taskId'] as String,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      error: json['error'] as String?,
      newUrl: json['newUrl'] as String?,
      oldUrl: json['oldUrl'] as String?,
    );

Map<String, dynamic> _$RefreshAttemptToJson(RefreshAttempt instance) =>
    <String, dynamic>{
      'cause': instance.cause,
      'createdAt': instance.createdAt.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
      'downloaded': instance.downloaded,
      'error': instance.error,
      'id': instance.id,
      'newUrl': instance.newUrl,
      'oldUrl': instance.oldUrl,
      'outcome': instance.outcome,
      'strategy': instance.strategy,
      'taskId': instance.taskId,
    };
