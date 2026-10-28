// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/cookie_list.dart';
import '../models/delete_cookies_result.dart';
import '../models/export_cookies_result.dart';
import '../models/format.dart';
import '../models/import_cookies_body.dart';
import '../models/import_cookies_result.dart';

part 'cookies_client.g.dart';

@RestApi()
abstract class CookiesClient {
  factory CookiesClient(Dio dio, {String? baseUrl}) = _CookiesClient;

  /// Delete the cookies of a domain.
  ///
  /// Deletes every cookie stored for exactly this domain (subdomains are separate domains).
  ///
  /// [domain] - Domain whose cookies are deleted.
  @DELETE('/v1/cookies')
  Future<DeleteCookiesResult> deleteCookies({
    @Query('domain') required String domain,
  });

  /// List stored cookies.
  ///
  /// Lists the cookie store without values. Cookie values are encrypted at rest and only returned by export-cookies.
  ///
  /// [domain] - Only cookies of exactly this domain (case-insensitive, no subdomains).
  ///
  /// [name] - Only cookies with this name.
  @GET('/v1/cookies')
  Future<CookieList> listCookies({
    @Query('domain') String? domain,
    @Query('name') String? name,
  });

  /// Export cookies.
  ///
  /// Returns the unexpired cookies, values included, as a JSON or Netscape cookies.txt file.
  ///
  /// [domain] - Only cookies of exactly this domain (case-insensitive, no subdomains).
  ///
  /// [name] - Only cookies with this name.
  ///
  /// [format] - File format.
  @GET('/v1/cookies/export')
  Future<ExportCookiesResult> exportCookies({
    @Query('format') Format? format = Format.valueJson,
    @Query('domain') String? domain,
    @Query('name') String? name,
  });

  /// Import cookies.
  ///
  /// Stores the cookies of a JSON or Netscape cookies.txt file. A cookie with the same domain, name, path and partition key is replaced. Rejected cookies are listed in the result; the request fails only when the document cannot be read.
  @POST('/v1/cookies/import')
  Future<ImportCookiesResult> importCookies({
    @Body() required ImportCookiesBody body,
  });

  /// Delete a cookie.
  ///
  /// [id] - Cookie ID.
  @DELETE('/v1/cookies/{id}')
  Future<void> deleteCookie({@Path('id') required String id});
}
