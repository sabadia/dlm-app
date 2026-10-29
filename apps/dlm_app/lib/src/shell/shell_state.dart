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

/// The selected downloads as the daemon last reported them (selected ids that
/// no longer exist are skipped).
final selectedTasksProvider = Provider<List<Task>>((ref) {
  final ids = ref.watch(selectionProvider);
  return [
    for (final id in ids)
      if (ref.watch(taskProvider(id)) case final Task t) t,
  ];
});
