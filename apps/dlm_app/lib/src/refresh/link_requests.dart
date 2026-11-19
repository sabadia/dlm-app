import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A task that waits for a new link, and the page to get it from.
class LinkRequest {
  /// Creates a request.
  const LinkRequest({
    required this.taskId,
    required this.name,
    required this.pageUrl,
    this.deadline,
  });

  /// The waiting task.
  final String taskId;

  /// Its name, for the banner.
  final String name;

  /// The page the download was started from.
  final String pageUrl;

  /// When the daemon stops waiting, if it says.
  final DateTime? deadline;
}

/// The tasks in `awaiting_link` that can be renewed by opening their page.
///
/// A task lands here when the daemon announces `task.refresh.requested` (the
/// browser extension takes the next matching download from that page) and
/// leaves when it is no longer waiting. Tasks already waiting when the app
/// connects are found in the list. A task with no page address has nothing to
/// open, so it is not listed.
class LinkRequests extends Notifier<List<LinkRequest>> {
  @override
  List<LinkRequest> build() {
    final engine = ref.watch(syncEngineProvider);
    final sub = engine.events.listen(_onEvent);
    // A request announced while the stream was down was missed, and one that
    // was settled meanwhile never told: ask again after every reconnection.
    final conn = engine.connection.listen((s) {
      if (s == HubConnectionState.connected) unawaited(_load());
    });
    ref.onDispose(() {
      unawaited(sub.cancel());
      unawaited(conn.cancel());
    });
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      final found = <LinkRequest>[];
      String? cursor;
      do {
        final page = await repo.list(
          const TaskQuery(statuses: {TaskStatus.awaitingLink}),
          cursor: cursor,
          limit: 100,
        );
        for (final t in page.tasks) {
          // The page, not the expired file link: that is where a new link is.
          final url = t.source.pageUrl;
          if (url == null || url.isEmpty) continue;
          found.add(
            LinkRequest(
              taskId: t.id,
              name: t.name ?? t.resource?.name ?? t.id,
              pageUrl: url,
              deadline: state
                  .where((x) => x.taskId == t.id)
                  .map((x) => x.deadline)
                  .firstOrNull,
            ),
          );
        }
        cursor = page.nextCursor;
      } while (cursor != null);
      if (!ref.mounted) return;
      // What the daemon lists is what waits: requests it no longer lists are
      // dropped, the ones announced meanwhile stay.
      final listed = {for (final r in found) r.taskId};
      state = [
        ...found,
        for (final x in state)
          if (!listed.contains(x.taskId) && x.deadline != null) x,
      ];
    } on Object {
      // Not connected yet, or the daemon refused the list: the events still
      // tell of every request from now on.
    }
  }

  void _onEvent(StreamEvent event) {
    switch (event) {
      case StreamEventTaskRefreshRequestedEvent(:final data, :final taskId):
        if (taskId == null) return;
        _add(
          LinkRequest(
            taskId: taskId,
            name: data.name,
            pageUrl: data.pageUrl,
            deadline: data.deadline,
          ),
        );
      case StreamEventTaskStatusEvent(:final data, :final taskId):
        if (data.to != TaskStatus.awaitingLink.wire) _drop(taskId);
      case StreamEventTaskDeletedEvent(:final taskId):
        _drop(taskId);
      default:
        break;
    }
  }

  void _add(LinkRequest r) {
    state = [
      for (final x in state)
        if (x.taskId != r.taskId) x,
      r,
    ];
  }

  void _drop(String? id) {
    if (id == null || !state.any((x) => x.taskId == id)) return;
    state = [
      for (final x in state)
        if (x.taskId != id) x,
    ];
  }
}

/// The tasks waiting for a new link, oldest first.
final linkRequestsProvider = NotifierProvider<LinkRequests, List<LinkRequest>>(
  LinkRequests.new,
);
