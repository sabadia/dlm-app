import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../prefs/pref_providers.dart';
import '../routing/app_routes.dart';
import '../shell/queue_commands.dart';
import '../shell/shell_state.dart';

/// What the downloads list is divided into headed groups by.
enum ListGrouping {
  /// One flat list.
  none,

  /// By status.
  status,

  /// By queue.
  queue,

  /// By engine.
  engine,
}

/// How the downloads list is sorted and narrowed beyond the page it is on.
class ListOptions {
  /// Creates options; the default is the newest download first, so a download
  /// that was just added is at the top and nobody scrolls down to find it. The
  /// queue order (what drag-to-reorder changes) is one choice away.
  const ListOptions({
    this.sort = Sort.created,
    this.descending = true,
    this.engine,
    this.grouping = ListGrouping.none,
    this.chosen = false,
  });

  /// Whether the user picked the sort (or loaded a saved view). Until then a
  /// queue page shows its queue order, which is what dragging a row changes.
  final bool chosen;

  /// The sort key.
  final Sort sort;

  /// Whether the order runs from the largest to the smallest.
  final bool descending;

  /// Only downloads of this engine.
  final String? engine;

  /// How the rows are grouped under headings.
  final ListGrouping grouping;

  /// These options with [sort], [descending] or [grouping] replaced.
  ListOptions copyWith({
    Sort? sort,
    bool? descending,
    ListGrouping? grouping,
  }) => ListOptions(
    sort: sort ?? this.sort,
    descending: descending ?? this.descending,
    engine: engine,
    grouping: grouping ?? this.grouping,
    chosen: true,
  );

  /// The direction to ask the daemon for; null for its natural order.
  Order? get order => sort == Sort.position
      ? null
      : descending
      ? Order.desc
      : Order.asc;
}

/// The options a list shows: [options], except that a queue page the user has
/// not sorted shows the queue order (its rows can be dragged to reorder it).
ListOptions effectiveListOptions(ListOptions options, {String? queueId}) {
  if (queueId == null || options.chosen) return options;
  return ListOptions(
    sort: Sort.position,
    descending: false,
    engine: options.engine,
    grouping: options.grouping,
  );
}

/// The sort and engine filter of the downloads list.
class ListOptionsNotifier extends Notifier<ListOptions> {
  @override
  ListOptions build() => const ListOptions();

  /// Replaces the options: a change of the user's, so it is kept on queue
  /// pages too.
  void set(ListOptions options) => state = ListOptions(
    sort: options.sort,
    descending: options.descending,
    engine: options.engine,
    grouping: options.grouping,
    chosen: true,
  );
}

/// The sort and engine filter of the list.
final listOptionsProvider = NotifierProvider<ListOptionsNotifier, ListOptions>(
  ListOptionsNotifier.new,
);

/// The views the user saved.
final savedViewsProvider =
    NotifierProvider<PrefNotifier<List<SavedView>>, List<SavedView>>(
      () => PrefNotifier(UiPrefs.savedViews),
    );

/// The engines a download can run on, as the daemon names them.
const List<String> engineChoices = [
  'http',
  'bt',
  'ed2k',
  'ftp',
  'hls',
  'dash',
  'ytdlp',
  'browser',
];

/// The entries of the display menu: row height, grouping and sorting.
List<DlmMenuEntry> displayMenuEntries(
  BuildContext context,
  WidgetRef ref, {
  String? queueId,
}) {
  final l = AppLocalizations.of(context);
  final density = ref.read(densityProvider);
  final current = effectiveListOptions(
    ref.read(listOptionsProvider),
    queueId: queueId,
  );
  return [
    DlmMenuHeader(l.view_density),
    DlmMenuItem(
      label: l.view_density_comfortable,
      checked: density == Density.comfortable,
      onPressed: () => unawaited(
        ref.read(densityProvider.notifier).set(Density.comfortable),
      ),
    ),
    DlmMenuItem(
      label: l.view_density_compact,
      checked: density == Density.compact,
      onPressed: () =>
          unawaited(ref.read(densityProvider.notifier).set(Density.compact)),
    ),
    const DlmMenuSeparator(),
    DlmMenuHeader(l.view_group),
    for (final g in ListGrouping.values)
      DlmMenuItem(
        label: switch (g) {
          ListGrouping.none => l.view_group_none,
          ListGrouping.status => l.view_group_status,
          ListGrouping.queue => l.view_group_queue,
          ListGrouping.engine => l.view_group_engine,
        },
        checked: current.grouping == g,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            .set(current.copyWith(grouping: g)),
      ),
    const DlmMenuSeparator(),
    DlmMenuHeader(l.view_sort),
    for (final (sort, label) in [
      (Sort.position, l.view_sort_default),
      (Sort.created, l.view_sort_added),
      (Sort.name, l.view_sort_name),
      (Sort.size, l.view_sort_size),
      (Sort.completed, l.view_sort_completed),
    ])
      DlmMenuItem(
        label: label,
        checked: current.sort == sort,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            // The direction that reads naturally for the key: newest first for
            // "added", ascending for the others.
            .set(
              current.copyWith(sort: sort, descending: sort == Sort.created),
            ),
      ),
    if (current.sort != Sort.position) ...[
      DlmMenuItem(
        label: l.view_sort_asc,
        checked: !current.descending,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            .set(current.copyWith(descending: false)),
      ),
      DlmMenuItem(
        label: l.view_sort_desc,
        checked: current.descending,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            .set(current.copyWith(descending: true)),
      ),
    ],
  ];
}

/// The entries of the view menu: the engine filter and the saved views.
List<DlmMenuEntry> viewMenuEntries(
  BuildContext context,
  WidgetRef ref, {
  required DownloadsFilter filter,
}) {
  final l = AppLocalizations.of(context);
  final options = ref.read(listOptionsProvider);
  final views = ref.read(savedViewsProvider);
  final notifier = ref.read(listOptionsProvider.notifier);
  return [
    DlmMenuHeader(l.view_engine),
    DlmMenuItem(
      label: l.view_all_engines,
      checked: options.engine == null,
      onPressed: () => notifier.set(
        ListOptions(
          sort: options.sort,
          descending: options.descending,
          grouping: options.grouping,
        ),
      ),
    ),
    for (final e in engineChoices)
      DlmMenuItem(
        label: e,
        checked: options.engine == e,
        onPressed: () => notifier.set(
          ListOptions(
            sort: options.sort,
            descending: options.descending,
            engine: e,
            grouping: options.grouping,
          ),
        ),
      ),
    const DlmMenuSeparator(),
    DlmMenuHeader(l.view_saved),
    for (final v in views)
      DlmMenuItem(label: v.name, onPressed: () => applyView(context, ref, v)),
    DlmMenuItem(
      label: l.view_save,
      icon: const DlmIcon(DlmIconName.plus),
      onPressed: () => saveView(context, ref, filter: filter),
    ),
    if (views.isNotEmpty)
      for (final v in views)
        DlmMenuItem(
          label: l.view_delete(v.name),
          destructive: true,
          onPressed: () => ref.read(savedViewsProvider.notifier).set([
            for (final other in views)
              if (other.name != v.name) other,
          ]),
        ),
  ];
}

/// Goes to the page of [view] with its search, sort and engine filter.
void applyView(BuildContext context, WidgetRef ref, SavedView view) {
  final filter =
      DownloadsFilter.fromSegment(view.filter) ?? DownloadsFilter.all;
  final sort =
      Sort.values.where((s) => s.json == view.sort).firstOrNull ??
      Sort.position;
  ref
      .read(listOptionsProvider.notifier)
      .set(
        ListOptions(
          sort: sort,
          descending: view.descending,
          engine: view.engine,
        ),
      );
  ref.read(searchTextProvider.notifier).set(view.text);
  context.go(downloadsPath(filter));
}

/// Asks for a name and stores the current page, search, sort and engine
/// filter as a view; a view of the same name is replaced.
Future<void> saveView(
  BuildContext context,
  WidgetRef ref, {
  required DownloadsFilter filter,
}) async {
  final l = AppLocalizations.of(context);
  final name = await askName(
    context,
    title: l.view_save_title,
    confirmLabel: l.queue_save,
  );
  if (name == null) return;
  final options = ref.read(listOptionsProvider);
  final view = SavedView(
    name: name,
    filter: filter.name,
    text: ref.read(searchTextProvider).trim(),
    sort: options.sort.json ?? 'position',
    descending: options.descending,
    engine: options.engine,
  );
  final views = ref.read(savedViewsProvider);
  await ref.read(savedViewsProvider.notifier).set([
    for (final v in views)
      if (v.name != name) v,
    view,
  ]);
}
