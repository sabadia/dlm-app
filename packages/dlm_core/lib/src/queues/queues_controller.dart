import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';
import '../stores/entity_store.dart';

/// The queues, in position order. They are read once; the daemon's queue
/// events keep the cache (and so this list) current, and the answers of our own
/// commands are put in the cache at once.
class QueuesController extends AsyncNotifier<List<Queue>> {
  @override
  Future<List<Queue>> build() async {
    final api = ref.watch(apiProvider);
    final queues = ref.watch(taskStoreProvider).queues;
    final list = await guard(api.rest.queues.listQueues);
    queues.putAll([
      for (final q in list.queues ?? const <Queue>[]) MapEntry(q.id, q),
    ]);
    final stop = queues.listenAll(() {
      if (ref.mounted) state = AsyncData(_sorted(queues));
    });
    ref.onDispose(stop);
    return _sorted(queues);
  }

  static List<Queue> _sorted(EntityStore<Queue> queues) =>
      [for (final id in queues.ids) queues[id]!]
        ..sort((a, b) => a.position.compareTo(b.position));

  EntityStore<Queue> get _cache => ref.read(taskStoreProvider).queues;
  QueuesClient get _client => ref.read(apiProvider).rest.queues;

  Future<Queue> _store(Future<Queue> Function() call) async {
    final q = await guard(call);
    _cache.put(q.id, q);
    return q;
  }

  /// Creates a queue.
  Future<Queue> create(CreateQueueBody body) =>
      _store(() => _client.createQueue(body: body));

  /// Renames a queue or patches its settings.
  Future<Queue> edit(String id, UpdateQueueBody body) =>
      _store(() => _client.updateQueue(id: id, body: body));

  /// Starts a queue.
  Future<Queue> start(String id) => _store(() => _client.startQueue(id: id));

  /// Stops a queue.
  Future<Queue> stop(String id) => _store(() => _client.stopQueue(id: id));

  /// Moves a queue to [position] in the list.
  Future<Queue> reorder(String id, int position) => _store(
    () => _client.reorderQueue(
      id: id,
      body: PositionBody(position: position),
    ),
  );

  /// Replaces the settings overrides of a queue.
  Future<Queue> replaceSettings(String id, Settings settings) =>
      _store(() => _client.replaceQueueSettings(id: id, body: settings));

  /// Deletes a queue; its tasks move to [moveTasksTo] (default queue if null).
  Future<void> remove(String id, {String? moveTasksTo}) async {
    final removed = _cache.remove(id);
    try {
      await guard(() => _client.deleteQueue(id: id, moveTasksTo: moveTasksTo));
    } on Object {
      if (removed != null) _cache.put(id, removed);
      rethrow;
    }
  }
}
