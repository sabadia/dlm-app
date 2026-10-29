import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/contrast.dart';
import '../theme/theme.dart';

/// Series colours for charts: the Okabe-Ito set, which stays distinguishable
/// for the common kinds of colour blindness, each adjusted to reach 3:1
/// against the content surface.
class DlmChartPalette {
  const DlmChartPalette._(this.series);

  /// Builds the palette for [colors].
  factory DlmChartPalette.forColors(DlmColors colors) {
    const base = [
      Color(0xFF0072B2),
      Color(0xFFE69F00),
      Color(0xFF009E73),
      Color(0xFFD55E00),
      Color(0xFFCC79A7),
      Color(0xFF56B4E9),
    ];
    final min = colors.highContrast ? 4.5 : 3.0;
    return DlmChartPalette._([
      for (final c in base) ensureContrast(c, colors.content, minRatio: min),
    ]);
  }

  /// The colours, in the order they should be assigned to series.
  final List<Color> series;

  /// The colour of series [index]; repeats after the palette runs out.
  Color operator [](int index) => series[index % series.length];
}

/// The chart palette of the theme in scope.
DlmChartPalette dlmChartPalette(BuildContext context) =>
    DlmChartPalette.forColors(DlmTheme.of(context).colors);

/// One entry of a chart legend.
class DlmLegendItem {
  /// Creates a legend entry.
  const DlmLegendItem({required this.label, required this.color});

  /// The series name.
  final String label;

  /// The series colour.
  final Color color;
}

/// The frame around a chart: title, legend, optional controls and the chart
/// itself. A painted chart is invisible to assistive technology, so
/// [summary] (a sentence of the key facts) is required and is what a screen
/// reader gets instead.
class DlmChartFrame extends StatelessWidget {
  /// Creates a chart frame.
  const DlmChartFrame({
    required this.title,
    required this.summary,
    required this.child,
    this.legend = const [],
    this.trailing,
    this.height = 200,
    super.key,
  });

  /// Chart title.
  final String title;

  /// Text alternative of the chart.
  final String summary;

  /// The chart.
  final Widget child;

  /// Series legend.
  final List<DlmLegendItem> legend;

  /// Controls at the trailing edge of the title row (a range picker).
  final Widget? trailing;

  /// Height of the chart area.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final m = theme.metrics;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: theme.typography.subtitle),
                ),
              ),
              ?trailing,
            ],
          ),
          if (legend.isNotEmpty) ...[
            SizedBox(height: m.spacing.xs),
            ExcludeSemantics(
              child: Wrap(
                spacing: m.spacing.md,
                runSpacing: m.spacing.xs,
                children: [
                  for (final item in legend)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: m.iconSmall - 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        SizedBox(width: m.spacing.xs),
                        Text(
                          item.label,
                          style: theme.typography.caption.copyWith(
                            color: theme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          SizedBox(height: m.spacing.sm),
          Semantics(
            container: true,
            label: summary,
            child: ExcludeSemantics(
              child: SizedBox(height: height, child: child),
            ),
          ),
        ],
      ),
    );
  }
}
