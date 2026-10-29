import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';
import 'task_repository.dart';

/// A window onto the tasks matching a [TaskQuery]: the ids loaded so far, in
/// the daemon's order. The tasks themselves are in the `TaskStore`.
class TaskListState {
  /// Creates a state.
  const TaskListState({
    this.ids = const [],
    this.nextCursor,
    this.loading = false,
    this.loaded = false,
    this.error,
    this.total,
  });

  /// The loaded ids, in order.
  final List<String> ids;

  /// Cursor of the next page; null when everything is loaded.
  final String? nextCursor;

  /// Whether a request is running.
  final bool loading;

  /// Whether the first page has arrived.
  final bool loaded;

  /// The failure of the last request.
  final ApiFailure? error;

  /// How many tasks match the query in all, as of the last first page.
  final int? total;

  /// Whether more pages exist.
  bool get hasMore => nextCursor != null;

  /// A copy with the given fields replaced.
  TaskListState copyWith({
    List<String>? ids,
    String? Function()? nextCursor,
    bool? loading,
    bool? loaded,
    ApiFailure? Function()? error,
    int? total,
  }) => TaskListState(
    ids: ids ?? this.ids,
    nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
    loading: loading ?? this.loading,
    loaded: loaded ?? this.loaded,
    error: error != null ? error() : this.error,
    total: total ?? this.total,
  );
}

/// Loads and keeps a [TaskListState] fresh.
///
/// Pages are fetched on demand (`loadMore`). When tasks appear, disappear or
/// change status, the daemon's events patch the cached tasks at once; the
/// window itself is re-read after a short pause so a burst of events (a bulk
/// pause) costs one request.
class TaskListController extends Notifier<TaskListState> {
  /// Creates the controller of [query].
  TaskListController(this.query);

  /// What this list shows.
  final TaskQuery query;

  Timer? _debounce;
  var _epoch = 0;

  @override
  TaskListState build() {
    final store = ref.watch(taskStoreProvider);
    final delay = ref.watch(listRefreshDelayProvider);
    final sub = store.membershipChanged.listen((_) {
      if (!state.loaded) return;
      _debounce?.cancel();
      _debounce = Timer(delay, () => unawaited(refresh()));
    });
    ref.onDispose(() {
      unawaited(sub.cancel());
      _debounce?.cancel();
      _epoch++;
    });
    unawaited(Future.microtask(loadFirst));
    return const TaskListState(loading: true);
  }

  /// Loads the first page again (keeps what is shown until it arrives).
  Future<void> loadFirst() => _fetch(limit: _pageSize);

  /// Loads the next page.
  Future<void> loadMore() async {
    if (!ref.mounted) return;
    final cursor = state.nextCursor;
    if (cursor == null || state.loading) return;
    final epoch = _epoch;
    state = state.copyWith(loading: true, error: () => null);
    try {
      final page = await ref
          .read(taskRepositoryProvider)
          .list(query, cursor: cursor, limit: _pageSize);
      if (epoch != _epoch) return;
      ref.read(taskStoreProvider).tasks.putAll([
        for (final t in page.tasks) MapEntry(t.id, t),
      ]);
      final known = state.ids.toSet();
      state = state.copyWith(
        ids: [
          ...state.ids,
          for (final t in page.tasks)
            if (!known.contains(t.id)) t.id,
        ],
        nextCursor: () => page.nextCursor,
        loading: false,
      );
    } on ApiFailure catch (e) {
      if (epoch == _epoch) {
        state = state.copyWith(loading: false, error: () => e);
      }
    }
  }

  /// Re-reads the window that is shown (at least one page).
  Future<void> refresh() => _fetch(limit: _pageSize, upTo: state.ids.length);

  static const _pageSize = 100;

  Future<void> _fetch({required int limit, int upTo = 0}) async {
    if (!ref.mounted) return;
    final epoch = ++_epoch;
    state = state.copyWith(loading: true, error: () => null);
    final repo = ref.read(taskRepositoryProvider);
    final store = ref.read(taskStoreProvider);
    try {
      final ids = <String>[];
      int? total;
      String? cursor;
      do {
        final page = await repo.list(query, cursor: cursor, limit: limit);
        if (epoch != _epoch) return;
        store.tasks.putAll([for (final t in page.tasks) MapEntry(t.id, t)]);
        ids.addAll(page.tasks.map((t) => t.id));
        total ??= page.total;
        cursor = page.nextCursor;
      } while (cursor != null && ids.length < upTo);
      state = TaskListState(
        ids: ids,
        nextCursor: cursor,
        loaded: true,
        total: total,
      );
    } on ApiFailure catch (e) {
      if (epoch == _epoch) {
        state = state.copyWith(
          loading: false,
          loaded: state.loaded,
          error: () => e,
        );
      }
    }
  }
}
