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
import 'task_cells.dart';

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
  /// Creates options; the default is the daemon's own order.
  const ListOptions({
    this.sort = Sort.position,
    this.descending = false,
    this.engine,
    this.grouping = ListGrouping.none,
  });

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
  );

  /// The direction to ask the daemon for; null for its natural order.
  Order? get order => sort == Sort.position
      ? null
      : descending
      ? Order.desc
      : Order.asc;
}

/// The sort and engine filter of the downloads list.
class ListOptionsNotifier extends Notifier<ListOptions> {
  @override
  ListOptions build() => const ListOptions();

  /// Replaces the options.
  void set(ListOptions options) => state = options;
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

/// The columns of the downloads table the user chose to show; empty shows the
/// default set.
final downloadColumnsProvider =
    NotifierProvider<PrefNotifier<List<String>>, List<String>>(
      () => PrefNotifier(UiPrefs.columns('downloads')),
    );

/// The sort key of a table column, or null when the column cannot be sorted.
Sort? sortOfColumn(String columnId) => switch (columnId) {
  'name' => Sort.name,
  'size' => Sort.size,
  'added' => Sort.created,
  _ => null,
};

/// The column a sort key belongs to, or null for the daemon's order.
String? columnOfSort(Sort sort) => switch (sort) {
  Sort.name => 'name',
  Sort.size => 'size',
  Sort.created => 'added',
  _ => null,
};

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

/// The entries of the display menu: row height and which columns show.
List<DlmMenuEntry> displayMenuEntries(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations.of(context);
  final density = ref.read(densityProvider);
  final chosen = ref.read(downloadColumnsProvider);
  final columns = [
    for (final c in taskColumns(l))
      if (c.id != 'name') c,
  ];
  bool shown(String id) => chosen.isEmpty || chosen.contains(id);
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
        checked: ref.read(listOptionsProvider).grouping == g,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            .set(ref.read(listOptionsProvider).copyWith(grouping: g)),
      ),
    const DlmMenuSeparator(),
    DlmMenuHeader(l.view_columns),
    for (final c in columns)
      DlmMenuItem(
        label: c.label,
        checked: shown(c.id),
        onPressed: () {
          final now = {
            for (final other in columns)
              if (shown(other.id)) other.id,
          };
          shown(c.id) ? now.remove(c.id) : now.add(c.id);
          unawaited(
            ref.read(downloadColumnsProvider.notifier).set([
              for (final other in columns)
                if (now.contains(other.id)) other.id,
            ]),
          );
        },
      ),
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
