import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The ids of the selected downloads (the details pane shows the one, the
/// toolbar acts on all of them).
class SelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Replaces the selection.
  void set(Set<String> ids) => state = Set.unmodifiable(ids);

  /// Clears it.
  void clear() => state = const {};
}

/// The selected downloads.
final selectionProvider = NotifierProvider<SelectionNotifier, Set<String>>(
  SelectionNotifier.new,
);

/// What dragging downloads carries to a drop target (a queue in the sidebar).
class TaskDragData {
  /// Creates the payload for [ids].
  const TaskDragData(this.ids);

  /// The downloads being dragged.
  final List<String> ids;
}

/// The text typed into the toolbar search field.
class SearchTextNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// Sets the text.
  void set(String value) => state = value;
}

/// The toolbar search text.
final searchTextProvider = NotifierProvider<SearchTextNotifier, String>(
  SearchTextNotifier.new,
);

/// How long the search text must rest before the list searches for it.
const Duration searchDebounce = Duration(milliseconds: 250);

/// [searchTextProvider] once typing pauses: every change of the text is a new
/// query of the list, so a fast typist should not make one per key. Clearing
/// the box applies at once.
class DebouncedSearch extends Notifier<String> {
  Timer? _timer;

  @override
  String build() {
    ref.onDispose(() => _timer?.cancel());
    ref.listen(searchTextProvider, (_, next) {
      _timer?.cancel();
      if (next.trim().isEmpty) {
        state = '';
      } else {
        _timer = Timer(searchDebounce, () => state = next);
      }
    });
    return ref.read(searchTextProvider);
  }
}

/// The search text the lists use.
final debouncedSearchProvider = NotifierProvider<DebouncedSearch, String>(
  DebouncedSearch.new,
);

/// Asks the shell to focus the search field (a counter, so each request is a
/// new value).
class FocusSearchNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Requests focus.
  void request() => state++;
}

/// Search focus requests.
final focusSearchProvider = NotifierProvider<FocusSearchNotifier, int>(
  FocusSearchNotifier.new,
);

/// Asks the shell to open the add-downloads dialog (a counter), for the tray
/// and other places outside the page.
class AddRequestNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Text to put in the dialog for the next request (links from the
  /// clipboard); read and cleared by the shell.
  String? pendingText;

  /// Requests the dialog, optionally with [text] filled in.
  void request({String? text}) {
    pendingText = text;
    state++;
  }
}

/// Requests to add downloads.
final addRequestProvider = NotifierProvider<AddRequestNotifier, int>(
  AddRequestNotifier.new,
);

/// The selected downloads as the daemon last reported them (selected ids that
/// no longer exist are skipped).
final selectedTasksProvider = Provider<List<Task>>((ref) {
  final ids = ref.watch(selectionProvider);
  return [
    for (final id in ids)
      if (ref.watch(taskProvider(id)) case final Task t) t,
  ];
});
