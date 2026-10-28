// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'post_action.g.dart';

@JsonSerializable()
class PostAction {
  const PostAction({required this.kind, this.params});

  factory PostAction.fromJson(Map<String, Object?> json) =>
      _$PostActionFromJson(json);

  final String kind;
  final Map<String, String>? params;

  Map<String, Object?> toJson() => _$PostActionToJson(this);
}
