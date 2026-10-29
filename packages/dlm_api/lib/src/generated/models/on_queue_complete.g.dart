// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'on_queue_complete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnQueueComplete _$OnQueueCompleteFromJson(Map<String, dynamic> json) =>
    OnQueueComplete(
      action: json['action'] as String,
      args: (json['args'] as List<dynamic>?)?.map((e) => e as String).toList(),
      command: json['command'] as String?,
      delay: json['delay'] as String?,
    );

Map<String, dynamic> _$OnQueueCompleteToJson(OnQueueComplete instance) =>
    <String, dynamic>{
      'action': instance.action,
      'args': instance.args,
      'command': instance.command,
      'delay': instance.delay,
    };
