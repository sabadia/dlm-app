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
List<DlmMenuEntry> displayMenuEntries(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations.of(context);
  final density = ref.read(densityProvider);
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
        checked: ref.read(listOptionsProvider).sort == sort,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            .set(ref.read(listOptionsProvider).copyWith(sort: sort)),
      ),
    if (ref.read(listOptionsProvider).sort != Sort.position) ...[
      DlmMenuItem(
        label: l.view_sort_asc,
        checked: !ref.read(listOptionsProvider).descending,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            .set(ref.read(listOptionsProvider).copyWith(descending: false)),
      ),
      DlmMenuItem(
        label: l.view_sort_desc,
        checked: ref.read(listOptionsProvider).descending,
        onPressed: () => ref
            .read(listOptionsProvider.notifier)
            .set(ref.read(listOptionsProvider).copyWith(descending: true)),
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
