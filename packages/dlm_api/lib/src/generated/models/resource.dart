// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

import 'file.dart';

part 'resource.g.dart';

@JsonSerializable()
class Resource {
  const Resource({
    required this.name,
    required this.rangeSupported,
    required this.size,
    this.files,
  });

  factory Resource.fromJson(Map<String, Object?> json) =>
      _$ResourceFromJson(json);

  final List<File>? files;
  final String name;
  final bool rangeSupported;
  final int size;

  Map<String, Object?> toJson() => _$ResourceToJson(this);
}
