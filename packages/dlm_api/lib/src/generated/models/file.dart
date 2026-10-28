// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'file.g.dart';

@JsonSerializable()
class File {
  const File({
    required this.index,
    required this.name,
    required this.selected,
    required this.size,
    this.path,
  });

  factory File.fromJson(Map<String, Object?> json) => _$FileFromJson(json);

  final int index;
  final String name;
  final String? path;
  final bool selected;
  final int size;

  Map<String, Object?> toJson() => _$FileToJson(this);
}
