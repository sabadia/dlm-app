// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_selector_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskSelectorFilter _$TaskSelectorFilterFromJson(Map<String, dynamic> json) =>
    TaskSelectorFilter(
      queueId: json['queueId'] as String?,
      status: (json['status'] as List<dynamic>?)
          ?.map((e) => TaskSelectorFilterStatus.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$TaskSelectorFilterToJson(TaskSelectorFilter instance) =>
    <String, dynamic>{
      'queueId': instance.queueId,
      'status': instance.status
          ?.map((e) => _$TaskSelectorFilterStatusEnumMap[e]!)
          .toList(),
    };

const _$TaskSelectorFilterStatusEnumMap = {
  TaskSelectorFilterStatus.queued: 'queued',
  TaskSelectorFilterStatus.running: 'running',
  TaskSelectorFilterStatus.paused: 'paused',
  TaskSelectorFilterStatus.awaitingLink: 'awaiting_link',
  TaskSelectorFilterStatus.refreshing: 'refreshing',
  TaskSelectorFilterStatus.postprocessing: 'postprocessing',
  TaskSelectorFilterStatus.completed: 'completed',
  TaskSelectorFilterStatus.error: 'error',
  TaskSelectorFilterStatus.$unknown: r'$unknown',
};
