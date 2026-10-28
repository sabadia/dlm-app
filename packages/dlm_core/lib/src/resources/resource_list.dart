import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';

/// A list of entities the app manages (categories, logins, webhooks, plugins,
/// cookies): fetched once, changed with optimistic updates that are rolled
/// back when the daemon refuses.
abstract class ResourceList<T> extends AsyncNotifier<List<T>> {
  /// Reads the whole list.
  Future<List<T>> fetch(DlmApi api);

  @override
  Future<List<T>> build() {
    final api = ref.watch(apiProvider);
    return guard(() => fetch(api));
  }

  /// Reads the list again.
  Future<void> reload() async {
    final api = ref.read(apiProvider);
    state = AsyncData(await guard(() => fetch(api)));
  }

  /// Runs [call]. With [optimistic] the list is changed at once and put back
  /// if [call] fails; afterwards the list is read again so it shows what the
  /// daemon stored.
  Future<R> mutate<R>(
    Future<R> Function(DlmApi api) call, {
    List<T> Function(List<T> current)? optimistic,
  }) async {
    final api = ref.read(apiProvider);
    final before = state.value;
    if (optimistic != null && before != null) {
      state = AsyncData(optimistic(before));
    }
    try {
      final result = await guard(() => call(api));
      await reload();
      return result;
    } on Object {
      if (before != null) state = AsyncData(before);
      rethrow;
    }
  }
}

/// The categories (`/v1/categories`).
class CategoriesController extends ResourceList<Category> {
  @override
  Future<List<Category>> fetch(DlmApi api) async =>
      (await api.rest.categories.listCategories()).categories ?? const [];

  /// Adds a category.
  Future<Category> create(CreateCategoryBody body) =>
      mutate((api) => api.rest.categories.createCategory(body: body));

  /// Changes a category.
  Future<Category> edit(String id, UpdateCategoryBody body) =>
      mutate((api) => api.rest.categories.updateCategory(id: id, body: body));

  /// Removes a category.
  Future<void> remove(String id) => mutate(
    (api) => api.rest.categories.deleteCategory(id: id),
    optimistic: (list) => [
      for (final c in list)
        if (c.id != id) c,
    ],
  );
}

/// The stored site logins (`/v1/credentials`); secrets never leave the daemon.
class CredentialsController extends ResourceList<Credential> {
  @override
  Future<List<Credential>> fetch(DlmApi api) async =>
      (await api.rest.credentials.listCredentials()).credentials ?? const [];

  /// Stores a login.
  Future<Credential> create(CreateCredentialBody body) =>
      mutate((api) => api.rest.credentials.createCredential(body: body));

  /// Changes a login.
  Future<Credential> edit(String id, UpdateCredentialBody body) => mutate(
    (api) => api.rest.credentials.updateCredential(id: id, body: body),
  );

  /// Forgets a login.
  Future<void> remove(String id) => mutate(
    (api) => api.rest.credentials.deleteCredential(id: id),
    optimistic: (list) => [
      for (final c in list)
        if (c.id != id) c,
    ],
  );
}

/// The webhooks (`/v1/webhooks`).
class WebhooksController extends ResourceList<Webhook> {
  @override
  Future<List<Webhook>> fetch(DlmApi api) async =>
      (await api.rest.webhooks.listWebhooks()).webhooks ?? const [];

  /// Adds a webhook.
  Future<Webhook> create(CreateWebhookBody body) =>
      mutate((api) => api.rest.webhooks.createWebhook(body: body));

  /// Changes a webhook.
  Future<Webhook> edit(String id, UpdateWebhookBody body) =>
      mutate((api) => api.rest.webhooks.updateWebhook(id: id, body: body));

  /// Removes a webhook.
  Future<void> remove(String id) => mutate(
    (api) => api.rest.webhooks.deleteWebhook(id: id),
    optimistic: (list) => [
      for (final w in list)
        if (w.id != id) w,
    ],
  );

  /// Sends a test delivery.
  Future<void> test(String id) =>
      guard(() => ref.read(apiProvider).rest.webhooks.testWebhook(id: id));
}

/// The plugins (`/v1/plugins`).
class PluginsController extends ResourceList<Plugin> {
  @override
  Future<List<Plugin>> fetch(DlmApi api) async =>
      (await api.rest.plugins.listPlugins()).plugins ?? const [];

  /// Installs a plugin.
  Future<Plugin> install(InstallPluginBody body) =>
      mutate((api) => api.rest.plugins.installPlugin(body: body));

  /// Enables or disables a plugin.
  Future<Plugin> setEnabled(String name, {required bool enabled}) => mutate(
    (api) => api.rest.plugins.updatePlugin(
      name: name,
      body: UpdatePluginBody(enabled: enabled),
    ),
    optimistic: (list) => [
      for (final p in list)
        if (p.name == name)
          Plugin(
            enabled: enabled,
            installedAt: p.installedAt,
            name: p.name,
            source: p.source,
            updatedAt: p.updatedAt,
            version: p.version,
            description: p.description,
            error: p.error,
            hooks: p.hooks,
            net: p.net,
            title: p.title,
          )
        else
          p,
    ],
  );

  /// Removes a plugin.
  Future<void> remove(String name) => mutate(
    (api) => api.rest.plugins.deletePlugin(name: name),
    optimistic: (list) => [
      for (final p in list)
        if (p.name != name) p,
    ],
  );
}

/// The cookies (`/v1/cookies`); values stay in the daemon.
class CookiesController extends ResourceList<CookieInfo> {
  @override
  Future<List<CookieInfo>> fetch(DlmApi api) async =>
      (await api.rest.cookies.listCookies()).cookies ?? const [];

  /// Deletes every cookie of [domain].
  Future<void> removeDomain(String domain) => mutate(
    (api) => api.rest.cookies.deleteCookies(domain: domain),
    optimistic: (list) => [
      for (final c in list)
        if (c.domain != domain) c,
    ],
  );

  /// Imports cookies.
  Future<ImportCookiesResult> import(ImportCookiesBody body) =>
      mutate((api) => api.rest.cookies.importCookies(body: body));
}
