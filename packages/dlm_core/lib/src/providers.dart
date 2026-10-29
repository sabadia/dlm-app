import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import 'queues/queues_controller.dart';
import 'resources/resource_list.dart';
import 'session.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_repository.dart';
import 'stores/entity_store.dart';
import 'sync/sync_engine.dart';
import 'tasks/refresh_repository.dart';
import 'tasks/task_actions.dart';
import 'tasks/task_detail_repository.dart';
import 'tasks/task_list.dart';
import 'tasks/task_repository.dart';
import 'tasks/task_store.dart';

/// The connection to the daemon. The app overrides this once a profile is
/// connected; everything below is built from it.
final sessionProvider = Provider<DlmSession>(
  (ref) => throw StateError('no daemon is connected: override sessionProvider'),
);

/// The REST client.
final apiProvider = Provider<DlmApi>((ref) => ref.watch(sessionProvider).api);

/// Pause before a list re-reads its window after events changed its tasks.
final listRefreshDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 400),
);

/// The cached tasks, progress and queues.
final taskStoreProvider = Provider<TaskStore>((ref) {
  final store = TaskStore();
  ref.onDispose(store.dispose);
  return store;
});

/// Where tasks are read from and commands go to.
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => ApiTaskRepository(ref.watch(apiProvider)),
);

/// Where a task's link is renewed or replaced.
final refreshRepositoryProvider = Provider<RefreshRepository>(
  (ref) => ApiRefreshRepository(ref.watch(apiProvider)),
);

/// Where a task's segments, torrent swarm and chosen files are read and set.
final taskDetailRepositoryProvider = Provider<TaskDetailRepository>(
  (ref) => ApiTaskDetailRepository(ref.watch(apiProvider)),
);

/// The segments of one task. Read again when invalidated (the inspector does
/// that while the task runs).
final taskSegmentsProvider = FutureProvider.autoDispose
    .family<List<Segment>, String>(
      (ref, id) => ref.watch(taskDetailRepositoryProvider).segments(id),
    );

/// The swarm of one torrent task (null when there is none). Read again when
/// invalidated.
final taskTorrentProvider = FutureProvider.autoDispose
    .family<TorrentInfo?, String>(
      (ref, id) => ref.watch(taskDetailRepositoryProvider).torrent(id),
    );

/// The attempts to renew one task's link. Read again when invalidated (a
/// `task.refresh` event does that while the inspector shows it).
final taskRefreshesProvider =
    FutureProvider.family<List<RefreshAttempt>, String>(
      (ref, id) => ref.watch(refreshRepositoryProvider).history(id),
    );

/// Commands on tasks with optimistic updates.
final taskActionsProvider = Provider<TaskActions>(
  (ref) => TaskActions(
    ref.watch(taskRepositoryProvider),
    ref.watch(taskStoreProvider),
  ),
);

/// Keeps the cache current from the event stream; call `start()` once.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    hub: ref.watch(sessionProvider).hub,
    store: ref.watch(taskStoreProvider),
    onReset: () async {
      // Everything cached is gone: lists reload, others are read again by
      // whoever shows them.
      ref
        ..invalidate(taskListProvider)
        ..invalidate(queuesProvider)
        ..invalidate(globalSettingsProvider)
        ..invalidate(categoriesProvider)
        ..invalidate(credentialsProvider)
        ..invalidate(webhooksProvider)
        ..invalidate(pluginsProvider)
        ..invalidate(cookiesProvider)
        ..invalidate(statsProvider)
        ..invalidate(systemInfoProvider);
    },
    onSettingsUpdated: () => ref.invalidate(globalSettingsProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

/// One task, by id. Rebuilds only when that task changes.
final taskProvider = Provider.family<Task?, String>(
  (ref, id) => _watchEntity(ref, ref.watch(taskStoreProvider).tasks, id),
);

/// The live progress of one task, by id.
final taskProgressProvider = Provider.family<ProgressData?, String>(
  (ref, id) => _watchEntity(ref, ref.watch(taskStoreProvider).progress, id),
);

/// One queue, by id.
final queueProvider = Provider.family<Queue?, String>(
  (ref, id) => _watchEntity(ref, ref.watch(taskStoreProvider).queues, id),
);

/// A window onto the tasks of a query.
final taskListProvider =
    NotifierProvider.family<TaskListController, TaskListState, TaskQuery>(
      TaskListController.new,
    );

T? _watchEntity<T>(Ref ref, EntityStore<T> store, String id) {
  final stop = store.listen(id, ref.invalidateSelf);
  ref.onDispose(stop);
  return store[id];
}

/// Where settings are read from and written to.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ApiSettingsRepository(ref.watch(apiProvider)),
);

/// The global settings with their version.
final globalSettingsProvider =
    AsyncNotifierProvider<GlobalSettingsController, GlobalSettings>(
      GlobalSettingsController.new,
    );

/// The description of every settings field (types, groups, bounds, levels).
final settingsSchemaProvider = FutureProvider<Schema>(
  (ref) => ref.watch(settingsRepositoryProvider).schema(),
);

/// Effective settings of a task with the origin of each value.
final taskEffectiveSettingsProvider =
    FutureProvider.family<EffectiveSettings, String>(
      (ref, id) => ref.watch(settingsRepositoryProvider).effectiveForTask(id),
    );

/// Effective settings of a queue with the origin of each value.
final queueEffectiveSettingsProvider =
    FutureProvider.family<EffectiveSettings, String>(
      (ref, id) => ref.watch(settingsRepositoryProvider).effectiveForQueue(id),
    );

/// The queues in order.
final queuesProvider = AsyncNotifierProvider<QueuesController, List<Queue>>(
  QueuesController.new,
);

/// The categories.
final categoriesProvider =
    AsyncNotifierProvider<CategoriesController, List<Category>>(
      CategoriesController.new,
    );

/// The stored site logins.
final credentialsProvider =
    AsyncNotifierProvider<CredentialsController, List<Credential>>(
      CredentialsController.new,
    );

/// The webhooks.
final webhooksProvider =
    AsyncNotifierProvider<WebhooksController, List<Webhook>>(
      WebhooksController.new,
    );

/// The plugins.
final pluginsProvider = AsyncNotifierProvider<PluginsController, List<Plugin>>(
  PluginsController.new,
);

/// The cookies.
final cookiesProvider =
    AsyncNotifierProvider<CookiesController, List<CookieInfo>>(
      CookiesController.new,
    );

/// Download statistics (read again when invalidated).
final statsProvider = FutureProvider<StatsBody>(
  (ref) => guard(ref.watch(apiProvider).rest.tasks.getStats),
);

/// What the daemon says about itself: version, paths and the state of its
/// tools (ffmpeg, yt-dlp, browser). Read again when invalidated.
final systemInfoProvider = FutureProvider<SystemInfo>(
  (ref) => guard(ref.watch(apiProvider).rest.system.getSystemInfo),
);

/// The state of the internal headless browser.
final browserStatusProvider = FutureProvider<Status>(
  (ref) => guard(ref.watch(apiProvider).rest.browser.getBrowserStatus),
);

/// The retry policy of the app's provider container
/// (`ProviderContainer(retry: dlmRetry)`).
///
/// Riverpod retries failed providers by default. A daemon that is starting or
/// restarting deserves a few retries; a refusal (`ApiProblem`) or a cancelled
/// request never gets better by asking again.
Duration? dlmRetry(int retryCount, Object error) {
  if (retryCount >= 3 || error is! ApiConnectionFailure) return null;
  return Duration(milliseconds: 500 * (1 << retryCount));
}
