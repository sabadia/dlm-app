// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_webhook_body.dart';
import '../models/update_webhook_body.dart';
import '../models/webhook.dart';
import '../models/webhook_list.dart';

part 'webhooks_client.g.dart';

@RestApi()
abstract class WebhooksClient {
  factory WebhooksClient(Dio dio, {String? baseUrl}) = _WebhooksClient;

  /// List webhooks.
  ///
  /// Webhooks receive a signed JSON POST for the events they subscribe to. Secrets are never returned.
  @GET('/v1/webhooks')
  Future<WebhookList> listWebhooks();

  /// Create a webhook
  @POST('/v1/webhooks')
  Future<Webhook> createWebhook({@Body() required CreateWebhookBody body});

  /// Delete a webhook.
  ///
  /// [id] - Webhook ID.
  @DELETE('/v1/webhooks/{id}')
  Future<void> deleteWebhook({@Path('id') required String id});

  /// Get a webhook.
  ///
  /// [id] - Webhook ID.
  @GET('/v1/webhooks/{id}')
  Future<Webhook> getWebhook({@Path('id') required String id});

  /// Update a webhook.
  ///
  /// [id] - Webhook ID.
  @PATCH('/v1/webhooks/{id}')
  Future<Webhook> updateWebhook({
    @Path('id') required String id,
    @Body() required UpdateWebhookBody body,
  });

  /// Send a test event.
  ///
  /// Delivers a webhook.test event now (one attempt, even when the webhook is disabled). Answers 502 when the endpoint does not accept it.
  ///
  /// [id] - Webhook ID.
  @POST('/v1/webhooks/{id}/test')
  Future<void> testWebhook({@Path('id') required String id});
}
