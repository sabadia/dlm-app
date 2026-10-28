// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_credential_body.dart';
import '../models/credential.dart';
import '../models/credential_list.dart';
import '../models/update_credential_body.dart';

part 'credentials_client.g.dart';

@RestApi()
abstract class CredentialsClient {
  factory CredentialsClient(Dio dio, {String? baseUrl}) = _CredentialsClient;

  /// List stored logins.
  ///
  /// Stored logins answer HTTP Basic and Digest challenges of downloads from their host. Passwords are never returned.
  @GET('/v1/credentials')
  Future<CredentialList> listCredentials();

  /// Store a login
  @POST('/v1/credentials')
  Future<Credential> createCredential({
    @Body() required CreateCredentialBody body,
  });

  /// Delete a stored login.
  ///
  /// [id] - Credential ID.
  @DELETE('/v1/credentials/{id}')
  Future<void> deleteCredential({@Path('id') required String id});

  /// Get a stored login.
  ///
  /// [id] - Credential ID.
  @GET('/v1/credentials/{id}')
  Future<Credential> getCredential({@Path('id') required String id});

  /// Update a stored login.
  ///
  /// [id] - Credential ID.
  @PATCH('/v1/credentials/{id}')
  Future<Credential> updateCredential({
    @Path('id') required String id,
    @Body() required UpdateCredentialBody body,
  });
}
