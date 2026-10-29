// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenList _$TokenListFromJson(Map<String, dynamic> json) => TokenList(
  tokens: (json['tokens'] as List<dynamic>?)
      ?.map((e) => Token.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$TokenListToJson(TokenList instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'tokens': instance.tokens,
};
