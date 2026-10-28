// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_cancelled_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionCancelledData _$ActionCancelledDataFromJson(Map<String, dynamic> json) =>
    ActionCancelledData(
      action: json['action'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$ActionCancelledDataToJson(
  ActionCancelledData instance,
) => <String, dynamic>{'action': instance.action, 'reason': instance.reason};
