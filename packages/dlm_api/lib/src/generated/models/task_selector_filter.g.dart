// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_selector_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskSelectorFilter _$TaskSelectorFilterFromJson(Map<String, dynamic> json) =>
    TaskSelectorFilter(
      archived: json['archived'] == null
          ? null
          : TaskSelectorFilterArchived.fromJson(json['archived'] as String),
      category: json['category'] as String?,
      engine: json['engine'] as String?,
      label: json['label'] as String?,
      q: json['q'] as String?,
      queueId: json['queueId'] as String?,
      status: (json['status'] as List<dynamic>?)
          ?.map((e) => TaskSelectorFilterStatus.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$TaskSelectorFilterToJson(TaskSelectorFilter instance) =>
    <String, dynamic>{
      'archived': ?_$TaskSelectorFilterArchivedEnumMap[instance.archived],
      'category': ?instance.category,
      'engine': ?instance.engine,
      'label': ?instance.label,
      'q': ?instance.q,
      'queueId': ?instance.queueId,
      'status': ?instance.status
          ?.map((e) => _$TaskSelectorFilterStatusEnumMap[e]!)
          .toList(),
    };

const _$TaskSelectorFilterArchivedEnumMap = {
  TaskSelectorFilterArchived.exclude: 'exclude',
  TaskSelectorFilterArchived.only: 'only',
  TaskSelectorFilterArchived.any: 'any',
  TaskSelectorFilterArchived.$unknown: r'$unknown',
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
