import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How often the map is read again while the download runs; the daemon
/// checkpoints the segments about once a second.
const Duration segmentsRefresh = Duration(seconds: 2);

/// The byte ranges a download fetches in parallel and how much of each is done.
class SegmentsTab extends ConsumerStatefulWidget {
  /// Creates the tab for the task [id].
  const SegmentsTab({required this.id, super.key});

  /// The task.
  final String id;

  @override
  ConsumerState<SegmentsTab> createState() => _SegmentsTabState();
}

class _SegmentsTabState extends ConsumerState<SegmentsTab> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _follow(bool running) {
    if (!running) {
      _timer?.cancel();
      _timer = null;
    } else {
      _timer ??= Timer.periodic(
        segmentsRefresh,
        (_) => ref.invalidate(taskSegmentsProvider(widget.id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final task = ref.watch(taskProvider(widget.id));
    _follow(task?.statusKind.isActive ?? false);
    // Keep the last map on screen while the next one is read.
    final segments = ref.watch(taskSegmentsProvider(widget.id)).value;
    if (segments == null) return const SizedBox.shrink();
    if (segments.isEmpty) return DlmEmptyState(title: l.seg_none);

    final total = segments.fold<int>(0, (s, e) => s + (e.end - e.start));
    final done = segments.fold<int>(0, (s, e) => s + e.done);
    final percent = total <= 0 ? 0 : (done * 100 ~/ total);
    final palette = dlmChartPalette(context);
    return Padding(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.seg_summary(segments.length, percent),
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: theme.metrics.spacing.sm),
          DlmChartFrame(
            title: l.insp_tab_segments,
            summary: l.seg_summary(segments.length, percent),
            legend: [
              DlmLegendItem(label: l.seg_done, color: palette[0]),
              DlmLegendItem(label: l.seg_todo, color: theme.colors.separator),
            ],
            height: 64,
            child: Semantics(
              label: l.seg_label,
              child: CustomPaint(
                painter: SegmentsPainter(
                  segments: segments,
                  done: palette[0],
                  todo: theme.colors.separator,
                  gap: theme.colors.raised,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws one cell per segment as wide as its share of the file, filled up to
/// the part already downloaded.
class SegmentsPainter extends CustomPainter {
  /// Creates the painter.
  SegmentsPainter({
    required this.segments,
    required this.done,
    required this.todo,
    required this.gap,
  });

  /// The segments in file order.
  final List<Segment> segments;

  /// Colour of what is downloaded.
  final Color done;

  /// Colour of what is not.
  final Color todo;

  /// Colour of the thin line between two cells.
  final Color gap;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (s, e) => s + (e.end - e.start));
    if (total <= 0 || size.width <= 0) return;
    for (final s in segments) {
      final length = s.end - s.start;
      if (length <= 0) continue;
      final x = s.start / total * size.width;
      final w = length / total * size.width;
      final fraction = (s.done / length).clamp(0.0, 1.0);
      canvas
        ..drawRect(Rect.fromLTWH(x, 0, w, size.height), Paint()..color = todo)
        ..drawRect(
          Rect.fromLTWH(x, 0, w * fraction, size.height),
          Paint()..color = done,
        )
        ..drawRect(Rect.fromLTWH(x, 0, 1, size.height), Paint()..color = gap);
    }
  }

  @override
  bool shouldRepaint(SegmentsPainter old) =>
      old.segments != segments || old.done != done || old.todo != todo;
}
