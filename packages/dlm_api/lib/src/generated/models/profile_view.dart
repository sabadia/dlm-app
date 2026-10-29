// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'profile_view.g.dart';

@JsonSerializable()
class ProfileView {
  const ProfileView({required this.index, required this.speedLimit});

  factory ProfileView.fromJson(Map<String, Object?> json) =>
      _$ProfileViewFromJson(json);

  final int index;
  final int speedLimit;

  Map<String, Object?> toJson() => _$ProfileViewToJson(this);
}
