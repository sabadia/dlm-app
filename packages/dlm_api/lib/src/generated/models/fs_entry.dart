// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'fs_entry.g.dart';

@JsonSerializable()
class FsEntry {
  const FsEntry({required this.name, required this.path});

  factory FsEntry.fromJson(Map<String, Object?> json) =>
      _$FsEntryFromJson(json);

  final String name;

  /// Absolute path, usable as the path of the next listing.
  final String path;

  Map<String, Object?> toJson() => _$FsEntryToJson(this);
}
