import 'dart:math' as math;

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format/dlm_format.dart';

/// How many speed samples the graph keeps (one per progress event, about one
/// a second).
const int speedSamples = 120;

/// The recent download speeds of one task, oldest first, collected from its
/// progress events for as long as somebody watches them. Nothing is stored:
/// the graph starts empty when the pane is opened.
class SpeedHistory extends Notifier<List<int>> {
  /// Creates the history of the task [id].
  SpeedHistory(this.id);

  /// The task.
  final String id;

  @override
  List<int> build() {
    ref.listen(taskProgressProvider(id), (_, next) {
      if (next == null) return;
      final all = [...state, next.speed];
      state = all.length > speedSamples
          ? all.sublist(all.length - speedSamples)
          : all;
    });
    return const [];
  }
}

/// The speed history of a task.
final speedHistoryProvider =
    NotifierProvider.family<SpeedHistory, List<int>, String>(SpeedHistory.new);

/// A live graph of the download speed.
class SpeedTab extends ConsumerWidget {
  /// Creates the tab for the task [id].
  const SpeedTab({required this.id, super.key});

  /// The task.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final samples = ref.watch(speedHistoryProvider(id));
    final palette = dlmChartPalette(context);
    final peak = samples.fold<int>(0, math.max);
    final now = samples.isEmpty ? 0 : samples.last;
    return Padding(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      child: samples.isEmpty
          ? DlmEmptyState(title: l.speed_title, message: l.speed_waiting)
          : DlmChartFrame(
              title: l.speed_title,
              summary: l.speed_summary(
                context.speed(now) ?? '0',
                context.speed(peak) ?? '0',
                samples.length,
              ),
              legend: [DlmLegendItem(label: l.speed_series, color: palette[0])],
              height: 180,
              child: CustomPaint(
                painter: _SpeedPainter(
                  samples: samples,
                  peakLabel: context.speed(peak) ?? '',
                  line: palette[0],
                  grid: theme.colors.separator,
                  text: theme.colors.textSecondary,
                  style: theme.typography.caption,
                ),
                size: Size.infinite,
              ),
            ),
    );
  }
}

class _SpeedPainter extends CustomPainter {
  _SpeedPainter({
    required this.samples,
    required this.peakLabel,
    required this.line,
    required this.grid,
    required this.text,
    required this.style,
  });

  final List<int> samples;
  final String peakLabel;
  final Color line;
  final Color grid;
  final Color text;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final peak = math.max(1, samples.fold<int>(0, math.max));
    final label = TextPainter(
      text: TextSpan(
        text: peakLabel,
        style: style.copyWith(color: text),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final top = label.height + 2;
    final h = size.height - top;
    canvas
      ..drawLine(Offset(0, top), Offset(size.width, top), Paint()..color = grid)
      ..drawLine(
        Offset(0, size.height),
        Offset(size.width, size.height),
        Paint()..color = grid,
      );
    label.paint(canvas, Offset.zero);

    final step = size.width / math.max(1, speedSamples - 1);
    final offset = size.width - step * (samples.length - 1);
    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final p = Offset(offset + i * step, size.height - samples[i] / peak * h);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(offset, size.height)
      ..close();
    canvas
      ..drawPath(fill, Paint()..color = line.withValues(alpha: 0.15))
      ..drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_SpeedPainter old) =>
      old.samples != samples ||
      old.peakLabel != peakLabel ||
      old.line != line ||
      old.grid != grid;
}
