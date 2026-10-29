import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/task_format.dart';
import '../settings/settings_form.dart';
import '../shell/shell_state.dart';
import 'files_tab.dart';
import 'overview_tab.dart';
import 'segments_tab.dart';
import 'source_tab.dart';
import 'speed_tab.dart';
import 'torrent_tab.dart';

/// The pages of the details pane.
enum InspectorTab {
  /// Status, progress, where it goes, times, last error.
  overview,

  /// The files of the download.
  files,

  /// The live speed graph.
  speed,

  /// The byte ranges fetched in parallel.
  segments,

  /// The swarm of a torrent.
  torrent,

  /// The link and its renewals.
  source,

  /// The settings this download overrides.
  settings,
}

/// The tab the details pane is on; it stays when another download is picked.
class InspectorTabNotifier extends Notifier<InspectorTab> {
  @override
  InspectorTab build() => InspectorTab.overview;

  /// Switches tab.
  void set(InspectorTab tab) => state = tab;
}

/// The selected tab of the details pane.
final inspectorTabProvider =
    NotifierProvider<InspectorTabNotifier, InspectorTab>(
      InspectorTabNotifier.new,
    );

/// The details pane: about the selected download, or a hint when none or
/// several are selected.
class InspectorPane extends ConsumerWidget {
  /// Creates the pane.
  const InspectorPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final selection = ref.watch(selectionProvider);

    final Widget body;
    if (selection.isEmpty) {
      body = DlmEmptyState(
        title: l.inspector_empty_title,
        message: l.inspector_empty_message,
      );
    } else if (selection.length > 1) {
      body = DlmEmptyState(
        title: l.insp_multi(selection.length),
        message: l.insp_multi_hint,
      );
    } else {
      body = _TaskDetails(id: selection.single);
    }
    return Semantics(
      container: true,
      label: l.insp_label,
      child: ColoredBox(color: theme.colors.raised, child: body),
    );
  }
}

class _TaskDetails extends ConsumerWidget {
  const _TaskDetails({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final task = ref.watch(taskProvider(id));
    final tab = ref.watch(inspectorTabProvider);
    if (task == null) return DlmEmptyState(title: l.insp_gone);
    final gap = theme.metrics.spacing.md;
    final torrent = task.engine == 'bt';
    // A torrent has no segments map and a plain download no swarm; a tab kept
    // from another download falls back to the overview.
    final shown = switch (tab) {
      InspectorTab.torrent when !torrent => InspectorTab.overview,
      InspectorTab.segments when torrent => InspectorTab.overview,
      _ => tab,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gap, gap, gap, theme.metrics.spacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  taskTitle(l, task),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.subtitle,
                ),
              ),
              SizedBox(width: theme.metrics.spacing.sm),
              DlmBadge(
                label: statusLabel(l, task.statusKind),
                tone: statusTone(task.statusKind),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gap),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DlmTabBar<InspectorTab>(
              value: shown,
              onChanged: ref.read(inspectorTabProvider.notifier).set,
              tabs: [
                DlmOption(
                  value: InspectorTab.overview,
                  label: l.insp_tab_overview,
                ),
                DlmOption(value: InspectorTab.files, label: l.insp_tab_files),
                DlmOption(value: InspectorTab.speed, label: l.insp_tab_speed),
                if (torrent)
                  DlmOption(
                    value: InspectorTab.torrent,
                    label: l.insp_tab_torrent,
                  )
                else
                  DlmOption(
                    value: InspectorTab.segments,
                    label: l.insp_tab_segments,
                  ),
                DlmOption(value: InspectorTab.source, label: l.insp_tab_source),
                DlmOption(
                  value: InspectorTab.settings,
                  label: l.insp_tab_settings,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: theme.metrics.spacing.sm),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey((id, shown)),
            child: switch (shown) {
              InspectorTab.overview => OverviewTab(id: id),
              InspectorTab.files => FilesTab(id: id),
              InspectorTab.speed => SpeedTab(id: id),
              InspectorTab.segments => SegmentsTab(id: id),
              InspectorTab.torrent => TorrentTab(id: id),
              InspectorTab.source => SourceTab(id: id),
              InspectorTab.settings => SettingsForm(
                target: SettingsTarget.task(id),
                searchable: false,
              ),
            },
          ),
        ),
      ],
    );
  }
}
