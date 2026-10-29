import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/app_routes.dart';
import '../shell/shell_state.dart';
import '../shell/task_commands.dart';
import 'task_cells.dart';

/// The list of downloads of one filter (or one queue): a virtualized table
/// that pages in more rows as it is scrolled and follows the daemon's events.
class DownloadsScreen extends ConsumerWidget {
  /// Creates the page for [filter]; [queueId] narrows it to one queue.
  const DownloadsScreen({required this.filter, this.queueId, super.key});

  /// Which downloads to list.
  final DownloadsFilter filter;

  /// Restricts the list to this queue.
  final String? queueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final search = ref.watch(searchTextProvider).trim();
    final query = TaskQuery(
      queueId: queueId,
      statuses: filter.statuses,
      text: search.isEmpty ? null : search,
    );
    final state = ref.watch(taskListProvider(query));
    final list = ref.read(taskListProvider(query).notifier);

    if (!state.loaded) {
      return state.error != null
          ? DlmErrorState(
              title: l.list_error_title,
              message: state.error.toString(),
              retryLabel: l.list_retry,
              onRetry: list.loadFirst,
            )
          : DlmLoadingState(label: l.list_loading);
    }

    final store = ref.read(taskStoreProvider);
    final selection = ref.watch(selectionProvider);
    final hasMore = state.hasMore;
    final table = DlmDataTable<Task>(
      semanticLabel: l.table_downloads_label,
      labels: DlmTableLabels(
        sortedAscending: l.table_sorted_ascending,
        sortedDescending: l.table_sorted_descending,
        resizeColumn: l.table_resize_column,
        loadingRow: l.table_loading_row,
      ),
      columns: taskColumns(l),
      // One extra, not yet loaded row at the end asks for the next page.
      itemCount: state.ids.length + (hasMore ? 1 : 0),
      itemAt: (i) {
        if (i >= state.ids.length) {
          unawaited(Future.microtask(list.loadMore));
          return null;
        }
        return store.tasks[state.ids[i]];
      },
      rowId: (t) => t.id,
      rowSemanticLabel: (t) =>
          l.task_row_label(taskTitleOf(l, t), statusLabelOf(l, t)),
      selectedIds: selection,
      onSelectionChanged: (ids) => ref.read(selectionProvider.notifier).set({
        for (final id in ids) id as String,
      }),
      onRowSecondaryTap: (index, task, position) => showDlmContextMenu(
        context,
        position,
        taskMenuEntries(context, ref, task),
      ),
      emptyState: DlmEmptyState(
        title: search.isEmpty ? l.list_empty_title : l.list_empty_search_title,
        message: search.isEmpty
            ? l.list_empty_message
            : l.list_empty_search_message,
      ),
    );
    // Delete or Backspace removes the selection (after asking).
    void deleteSelection() {
      final ids = ref.read(selectionProvider).toList();
      if (ids.isNotEmpty) unawaited(deleteTasks(context, ref, ids));
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.delete): deleteSelection,
        const SingleActivator(LogicalKeyboardKey.backspace): deleteSelection,
      },
      child: table,
    );
  }
}
