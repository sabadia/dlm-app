import 'dart:async';
import 'dart:ui' as ui;

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../shell/feedback.dart';
import 'timeline_series.dart';

/// The traffic timeline for a bucket size and a split.
final timelineProvider = FutureProvider.autoDispose
    .family<Timeline, (Bucket, GroupBy)>(
      (ref, key) => ref.watch(statsRepositoryProvider).timeline(key.$1, key.$2),
    );

/// Statistics: totals, traffic over time, the history of finished downloads,
/// and the cleanup of old ones.
class StatisticsScreen extends ConsumerStatefulWidget {
  /// Creates the page.
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Bucket _bucket = Bucket.hour;
  GroupBy _groupBy = GroupBy.none;
  String _search = '';

  // Cleanup
  int _days = 30;
  bool _files = false;
  CleanupResult? _preview;
  bool _busy = false;

  Future<void> _previewCleanup() async {
    setState(() => _busy = true);
    try {
      final r = await ref
          .read(statsRepositoryProvider)
          .cleanup(olderThanDays: _days, files: _files, dryRun: true);
      if (mounted) setState(() => _preview = r);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cleanup() async {
    final l = AppLocalizations.of(context);
    final p = _preview!;
    final ok = await showDlmConfirm(
      context,
      title: l.st_cleanup_confirm_title(p.matched),
      message: _files ? l.st_cleanup_confirm_files : l.st_cleanup_confirm_list,
      confirmLabel: l.st_cleanup_go,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      final r = await ref
          .read(statsRepositoryProvider)
          .cleanup(olderThanDays: _days, files: _files);
      if (!mounted) return;
      setState(() => _preview = null);
      ref
        ..invalidate(statsProvider)
        ..invalidate(timelineProvider);
      showNotice(
        context,
        ref,
        r.failed > 0
            ? l.st_cleanup_done_failed(r.deleted, r.failed)
            : l.st_cleanup_done(r.deleted),
        tone: r.failed > 0 ? DlmTone.danger : DlmTone.success,
      );
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _totals(AppLocalizations l, DlmThemeData theme, StatsBody s) {
    final caption = theme.typography.caption.copyWith(
      color: theme.colors.textSecondary,
    );
    return DlmFormGroup(
      title: l.st_totals,
      children: [
        DlmFormRow(label: l.st_tasks, control: Text('${s.tasks}')),
        DlmFormRow(
          label: l.st_downloaded,
          control: Text(formatBytes(s.downloadedBytes) ?? '0'),
        ),
        DlmFormRow(
          label: l.st_by_status,
          control: Wrap(
            spacing: theme.metrics.spacing.xs,
            runSpacing: theme.metrics.spacing.xs,
            children: [
              for (final e in s.byStatus.entries)
                DlmBadge(label: '${e.key}: ${e.value}'),
            ],
          ),
        ),
        if ((s.byEngine ?? const []).isNotEmpty)
          DlmFormRow(
            label: l.st_by_engine,
            control: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in s.byEngine!)
                  Text(
                    '${e.engine}: ${e.tasks} · ${formatBytes(e.downloadedBytes) ?? '0'}',
                    style: caption,
                  ),
              ],
            ),
          ),
        for (final c in s.completed ?? const <CompletedStatsRow>[])
          DlmFormRow(
            label: l.st_completed_in(c.period.json ?? ''),
            control: Text('${c.tasks} · ${formatBytes(c.bytes) ?? '0'}'),
          ),
      ],
    );
  }

  Widget _chart(AppLocalizations l, DlmThemeData theme, Timeline t) {
    final series = TimelineSeries.of(t);
    final palette = dlmChartPalette(context);
    String groupName(String g) => g.isEmpty ? l.st_all_traffic : g;
    return DlmChartFrame(
      title: l.st_timeline,
      summary: l.st_timeline_summary(
        formatBytes(series.totalDown) ?? '0',
        formatBytes(series.totalUp) ?? '0',
      ),
      legend: [
        for (var i = 0; i < series.groups.length; i++)
          DlmLegendItem(label: groupName(series.groups[i]), color: palette[i]),
      ],
      child: series.isEmpty
          ? Center(child: Text(l.st_timeline_empty))
          : CustomPaint(
              painter: _TimelinePainter(
                series: series,
                colors: [
                  for (var i = 0; i < series.groups.length; i++) palette[i],
                ],
                grid: theme.colors.separator,
                text: theme.colors.textSecondary,
                style: theme.typography.caption,
              ),
              size: Size.infinite,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final gap = SizedBox(height: theme.metrics.spacing.lg);
    final stats = ref.watch(statsProvider);
    final timeline = ref.watch(timelineProvider((_bucket, _groupBy)));
    final history = ref.watch(
      taskListProvider(
        TaskQuery(
          statuses: const {TaskStatus.completed},
          sort: Sort.completed,
          order: Order.desc,
          text: _search.trim().isEmpty ? null : _search.trim(),
        ),
      ),
    );
    final historyList = ref.read(
      taskListProvider(
        TaskQuery(
          statuses: const {TaskStatus.completed},
          sort: Sort.completed,
          order: Order.desc,
          text: _search.trim().isEmpty ? null : _search.trim(),
        ),
      ).notifier,
    );
    final store = ref.read(taskStoreProvider);
    final date = DateFormat.yMMMd(l.localeName).add_Hm();

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      children: [
        if (stats.value != null)
          _totals(l, theme, stats.value!)
        else if (stats.hasError)
          DlmBanner(tone: DlmTone.danger, message: l.st_error)
        else
          DlmLoadingState(label: l.list_loading),
        gap,
        Wrap(
          spacing: theme.metrics.spacing.sm,
          runSpacing: theme.metrics.spacing.xs,
          children: [
            SizedBox(
              width: 160,
              child: DlmDropdown<Bucket>(
                semanticLabel: l.st_bucket,
                value: _bucket,
                choices: [
                  DlmChoice(value: Bucket.hour, label: l.st_bucket_hour),
                  DlmChoice(value: Bucket.day, label: l.st_bucket_day),
                ],
                onChanged: (v) => setState(() => _bucket = v),
              ),
            ),
            SizedBox(
              width: 180,
              child: DlmDropdown<GroupBy>(
                semanticLabel: l.st_group,
                value: _groupBy,
                choices: [
                  DlmChoice(value: GroupBy.none, label: l.st_group_none),
                  DlmChoice(value: GroupBy.engine, label: l.st_group_engine),
                  DlmChoice(value: GroupBy.queue, label: l.st_group_queue),
                ],
                onChanged: (v) => setState(() => _groupBy = v),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.metrics.spacing.sm),
        timeline.when(
          data: (t) => _chart(l, theme, t),
          loading: () => DlmLoadingState(label: l.list_loading),
          error: (e, _) => DlmBanner(tone: DlmTone.danger, message: l.st_error),
        ),
        gap,
        Text(l.st_history, style: theme.typography.subtitle),
        SizedBox(height: theme.metrics.spacing.xs),
        SizedBox(
          width: 320,
          child: DlmSearchField(
            placeholder: l.st_history_search,
            clearLabel: l.toolbar_search_clear,
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(height: theme.metrics.spacing.xs),
        if (!history.loaded)
          DlmLoadingState(label: l.list_loading)
        else if (history.ids.isEmpty)
          Text(l.st_history_empty)
        else ...[
          for (final id in history.ids)
            if (store.tasks[id] case final Task t)
              DlmListRow(
                title: t.name ?? t.source.currentUrl,
                subtitle:
                    '${formatBytes(t.size) ?? ''} · ${t.completedAt == null ? '' : date.format(t.completedAt!.toLocal())}',
                leading: const DlmIcon(DlmIconName.success),
              ),
          if (history.hasMore)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DlmButton(
                label: l.st_history_more,
                variant: DlmButtonVariant.plain,
                onPressed: () => unawaited(historyList.loadMore()),
              ),
            ),
        ],
        gap,
        DlmFormGroup(
          title: l.st_cleanup_title,
          footer: l.st_cleanup_desc,
          children: [
            DlmFormRow(
              label: l.st_cleanup_days,
              control: SizedBox(
                width: 140,
                child: DlmNumberField(
                  value: _days,
                  min: 0,
                  max: 36500,
                  invalidText: l.settings_invalid_number,
                  semanticLabel: l.st_cleanup_days,
                  suffix: Text(l.st_days),
                  onChanged: (v) => setState(() {
                    _days = (v ?? 0).toInt();
                    _preview = null;
                  }),
                ),
              ),
            ),
            DlmFormRow(
              label: l.st_cleanup_files,
              description: l.st_cleanup_files_desc,
              control: DlmSwitch(
                value: _files,
                semanticLabel: l.st_cleanup_files,
                onChanged: (v) => setState(() {
                  _files = v;
                  _preview = null;
                }),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.metrics.spacing.sm),
        Wrap(
          spacing: theme.metrics.spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DlmButton(
              label: l.st_cleanup_preview,
              onPressed: _busy ? null : () => unawaited(_previewCleanup()),
            ),
            if (_preview != null) ...[
              Text(
                l.st_cleanup_preview_result(
                  _preview!.matched,
                  formatBytes(_preview!.bytes) ?? '0',
                ),
              ),
              if (_preview!.matched > 0)
                DlmButton(
                  label: l.st_cleanup_go,
                  variant: DlmButtonVariant.destructive,
                  onPressed: _busy ? null : () => unawaited(_cleanup()),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Stacked bars of the bytes downloaded per bucket.
class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.series,
    required this.colors,
    required this.grid,
    required this.text,
    required this.style,
  });

  final TimelineSeries series;
  final List<Color> colors;
  final Color grid;
  final Color text;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final peak = series.peakDown;
    if (peak <= 0 || series.times.isEmpty) return;
    final label = TextPainter(
      text: TextSpan(
        text: formatBytes(peak) ?? '',
        style: style.copyWith(color: text),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final top = label.height + 2;
    final h = size.height - top;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()..color = grid,
    );
    label.paint(canvas, Offset.zero);
    final n = series.times.length;
    final slot = size.width / n;
    final bar = slot * 0.7;
    for (var i = 0; i < n; i++) {
      var y = size.height;
      for (var g = 0; g < series.groups.length; g++) {
        final bytes = series.down[i][series.groups[g]] ?? 0;
        if (bytes <= 0) continue;
        final height = bytes / peak * h;
        canvas.drawRect(
          Rect.fromLTWH(i * slot + (slot - bar) / 2, y - height, bar, height),
          Paint()..color = colors[g],
        );
        y -= height;
      }
    }
  }

  @override
  bool shouldRepaint(_TimelinePainter old) => old.series != series;
}
