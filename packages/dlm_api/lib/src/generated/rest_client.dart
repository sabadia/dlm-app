// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'auth/auth_client.dart';
import 'browser/browser_client.dart';
import 'capture/capture_client.dart';
import 'categories/categories_client.dart';
import 'config/config_client.dart';
import 'cookies/cookies_client.dart';
import 'credentials/credentials_client.dart';
import 'events/events_client.dart';
import 'system/system_client.dart';
import 'settings/settings_client.dart';
import 'logs/logs_client.dart';
import 'native_host/native_host_client.dart';
import 'pairing/pairing_client.dart';
import 'plugins/plugins_client.dart';
import 'queues/queues_client.dart';
import 'tasks/tasks_client.dart';
import 'refresh/refresh_client.dart';
import 'webhooks/webhooks_client.dart';

/// dlm-server API `v0.7.0`.
///
/// REST API of the dlm download manager daemon.
class RestClient {
  RestClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.7.0';

  AuthClient? _auth;
  BrowserClient? _browser;
  CaptureClient? _capture;
  CategoriesClient? _categories;
  ConfigClient? _config;
  CookiesClient? _cookies;
  CredentialsClient? _credentials;
  EventsClient? _events;
  SystemClient? _system;
  SettingsClient? _settings;
  LogsClient? _logs;
  NativeHostClient? _nativeHost;
  PairingClient? _pairing;
  PluginsClient? _plugins;
  QueuesClient? _queues;
  TasksClient? _tasks;
  RefreshClient? _refresh;
  WebhooksClient? _webhooks;

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  BrowserClient get browser =>
      _browser ??= BrowserClient(_dio, baseUrl: _baseUrl);

  CaptureClient get capture =>
      _capture ??= CaptureClient(_dio, baseUrl: _baseUrl);

  CategoriesClient get categories =>
      _categories ??= CategoriesClient(_dio, baseUrl: _baseUrl);

  ConfigClient get config => _config ??= ConfigClient(_dio, baseUrl: _baseUrl);

  CookiesClient get cookies =>
      _cookies ??= CookiesClient(_dio, baseUrl: _baseUrl);

  CredentialsClient get credentials =>
      _credentials ??= CredentialsClient(_dio, baseUrl: _baseUrl);

  EventsClient get events => _events ??= EventsClient(_dio, baseUrl: _baseUrl);

  SystemClient get system => _system ??= SystemClient(_dio, baseUrl: _baseUrl);

  SettingsClient get settings =>
      _settings ??= SettingsClient(_dio, baseUrl: _baseUrl);

  LogsClient get logs => _logs ??= LogsClient(_dio, baseUrl: _baseUrl);

  NativeHostClient get nativeHost =>
      _nativeHost ??= NativeHostClient(_dio, baseUrl: _baseUrl);

  PairingClient get pairing =>
      _pairing ??= PairingClient(_dio, baseUrl: _baseUrl);

  PluginsClient get plugins =>
      _plugins ??= PluginsClient(_dio, baseUrl: _baseUrl);

  QueuesClient get queues => _queues ??= QueuesClient(_dio, baseUrl: _baseUrl);

  TasksClient get tasks => _tasks ??= TasksClient(_dio, baseUrl: _baseUrl);

  RefreshClient get refresh =>
      _refresh ??= RefreshClient(_dio, baseUrl: _baseUrl);

  WebhooksClient get webhooks =>
      _webhooks ??= WebhooksClient(_dio, baseUrl: _baseUrl);
}
