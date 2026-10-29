// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'fs_entry.dart';

part 'fs_listing.g.dart';

@JsonSerializable()
class FsListing {
  const FsListing({
    required this.entries,
    required this.path,
    this.schema,
    this.parent,
    this.truncated,
  });

  factory FsListing.fromJson(Map<String, Object?> json) =>
      _$FsListingFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The sub-directories, sorted by name.
  final List<FsEntry>? entries;

  /// The directory above path; absent at a root.
  final String? parent;

  /// The listed directory; empty when the roots are listed.
  final String path;

  /// The directory has more sub-directories than were listed.
  final bool? truncated;

  Map<String, Object?> toJson() => _$FsListingToJson(this);
}
