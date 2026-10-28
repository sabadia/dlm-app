// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checksum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Checksum _$ChecksumFromJson(Map<String, dynamic> json) => Checksum(
  algorithm: json['algorithm'] as String,
  expected: json['expected'] as String,
);

Map<String, dynamic> _$ChecksumToJson(Checksum instance) => <String, dynamic>{
  'algorithm': instance.algorithm,
  'expected': instance.expected,
};
