// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_token_body.dart';
import '../models/created_token.dart';
import '../models/token_list.dart';
import '../models/who_am_i.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  /// Replace the primary token.
  ///
  /// Generates a new primary token, writes it to the daemon's token file and stops accepting the old one at once. The new token is in the answer and nowhere else in the API; a client keeps using it from now on. Named tokens are not affected. Needs an admin token.
  @POST('/v1/auth/token/rotate')
  Future<CreatedToken> rotateToken();

  /// List named tokens.
  ///
  /// The named tokens with their scope, creation time and when they were last used (never the secrets). Needs an admin token.
  @GET('/v1/auth/tokens')
  Future<TokenList> listTokens();

  /// Create a named token.
  ///
  /// Creates a token with the scope admin or read (read-only) for a dashboard, a script or another device, and returns its secret once. Needs an admin token.
  @POST('/v1/auth/tokens')
  Future<CreatedToken> createToken({@Body() required CreateTokenBody body});

  /// Revoke a named token.
  ///
  /// Revokes the token at once. Needs an admin token.
  ///
  /// [id] - Token ID.
  @DELETE('/v1/auth/tokens/{id}')
  Future<void> deleteToken({@Path('id') required String id});

  /// Who am I.
  ///
  /// The name and scope of the token the request carries, and whether the request is local and encrypted. A client uses it to tell what it may do.
  @GET('/v1/auth/whoami')
  Future<WhoAmI> whoami();
}
