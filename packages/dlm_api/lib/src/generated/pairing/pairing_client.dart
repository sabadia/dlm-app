// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/pairing.dart';
import '../models/pairing_body.dart';
import '../models/pairing_list.dart';
import '../models/pairing_state.dart';

part 'pairing_client.g.dart';

@RestApi()
abstract class PairingClient {
  factory PairingClient(Dio dio, {String? baseUrl}) = _PairingClient;

  /// List pairings waiting for an answer.
  ///
  /// The pairings the user has not answered yet, for an app that started after the request was made. Needs an admin token, from the machine the daemon runs on.
  @GET('/v1/pairing')
  Future<PairingList> listPairings();

  /// Ask to pair a browser extension.
  ///
  /// A browser extension asks to be given a token of its own. The request waits for the user to allow or deny it in the DLM app (event pairing.requested); it carries a six-digit code the extension shows and the user compares. Called by the native host with the primary token, so the extension never sees an admin token. Only from the machine the daemon runs on. At most 5 pairings wait at once (409 pairing.too_many).
  @POST('/v1/pairing')
  Future<Pairing> startPairing({@Body() required PairingBody body});

  /// Read a pairing.
  ///
  /// Where a pairing is: pending, approved, denied or expired. After the user allowed it, the first read also returns the token, once. A pairing is kept for a few minutes after it ends.
  ///
  /// [id] - Pairing ID.
  @GET('/v1/pairing/{id}')
  Future<PairingState> getPairing({@Path('id') required String id});

  /// Allow a pairing.
  ///
  /// The user allows the pairing: a token with the extension scope is issued and handed to the extension the next time it reads the pairing. If it is not read within five minutes the token is revoked. Needs an admin token, from the machine the daemon runs on.
  ///
  /// [id] - Pairing ID.
  @POST('/v1/pairing/{id}/approve')
  Future<Pairing> approvePairing({@Path('id') required String id});

  /// Refuse a pairing.
  ///
  /// The user refuses the pairing. Needs an admin token, from the machine the daemon runs on.
  ///
  /// [id] - Pairing ID.
  @POST('/v1/pairing/{id}/deny')
  Future<Pairing> denyPairing({@Path('id') required String id});
}
