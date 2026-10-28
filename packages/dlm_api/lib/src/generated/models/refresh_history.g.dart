// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshHistory _$RefreshHistoryFromJson(Map<String, dynamic> json) =>
    RefreshHistory(
      attempts: (json['attempts'] as List<dynamic>?)
          ?.map((e) => RefreshAttempt.fromJson(e as Map<String, dynamic>))
          .toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$RefreshHistoryToJson(RefreshHistory instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'attempts': instance.attempts,
    };
