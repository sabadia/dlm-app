import 'dart:math' as math;

import 'token_value.dart';

/// How tightly the interface is packed.
enum DlmDensity {
  /// Compact.
  compact(0.85),

  /// Regular.
  regular(1),

  /// Comfortable.
  comfortable(1.15);

  const DlmDensity(this.factor);

  /// Multiplier applied to control and row heights and to mid-size spacing.
  final double factor;
}

/// The spacing scale in logical pixels.
class DlmSpacing extends DlmTokenValue {
  /// Creates a [DlmSpacing].
  const DlmSpacing({
    this.xxs = 2,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  /// Hairline gaps (2 px).
  final double xxs;

  /// Tight gaps inside controls (4 px).
  final double xs;

  /// Small gaps between related items (8 px).
  final double sm;

  /// Default gap (12 px).
  final double md;

  /// Padding of groups and pages (16 px).
  final double lg;

  /// Gap between sections (24 px).
  final double xl;

  /// Page margins (32 px).
  final double xxl;

  /// The scale from smallest to largest.
  List<double> get scale => [xxs, xs, sm, md, lg, xl, xxl];

  DlmSpacing _scaled(double factor) => DlmSpacing(
    xxs: xxs,
    xs: xs,
    sm: (sm * factor).roundToDouble(),
    md: (md * factor).roundToDouble(),
    lg: (lg * factor).roundToDouble(),
    xl: xl,
    xxl: xxl,
  );

  @override
  List<Object?> get props => [xxs, xs, sm, md, lg, xl, xxl];
}

/// Corner radii.
class DlmRadii extends DlmTokenValue {
  /// Creates a [DlmRadii].
  const DlmRadii({
    required this.small,
    required this.control,
    required this.container,
    required this.window,
  });

  /// Chips, badges, small buttons.
  final double small;

  /// Buttons, inputs.
  final double control;

  /// Cards, popovers, dialogs.
  final double container;

  /// The window itself (0 when the system draws it).
  final double window;

  @override
  List<Object?> get props => [small, control, container, window];
}

/// A size range of a resizable region.
class DlmRange extends DlmTokenValue {
  /// Creates a [DlmRange].
  const DlmRange({required this.min, required this.ideal, required this.max});

  /// Smallest width.
  final double min;

  /// Width when first shown.
  final double ideal;

  /// Largest width.
  final double max;

  @override
  List<Object?> get props => [min, ideal, max];
}

/// Sizes, spacing and radii of a skin.
class DlmMetrics extends DlmTokenValue {
  /// Creates a [DlmMetrics].
  const DlmMetrics({
    required this.spacing,
    required this.radii,
    required this.controlHeightSmall,
    required this.controlHeight,
    required this.controlHeightLarge,
    required this.rowHeight,
    required this.minHitTarget,
    required this.borderWidth,
    required this.focusRingWidth,
    required this.focusRingOffset,
    required this.iconSmall,
    required this.icon,
    required this.iconLarge,
    required this.toolbarHeight,
    required this.titleBarHeight,
    required this.sidebarWidth,
    required this.inspectorWidth,
  });

  /// Spacing.
  final DlmSpacing spacing;

  /// Radii.
  final DlmRadii radii;

  /// Control height small.
  final double controlHeightSmall;

  /// Control height.
  final double controlHeight;

  /// Control height large.
  final double controlHeightLarge;

  /// A list or table row.
  final double rowHeight;

  /// Smallest pointer target of any interactive element (24 on desktop).
  final double minHitTarget;

  /// Border width.
  final double borderWidth;

  /// Focus ring width.
  final double focusRingWidth;

  /// Focus ring offset.
  final double focusRingOffset;

  /// Icon small.
  final double iconSmall;

  /// Icon.
  final double icon;

  /// Icon large.
  final double iconLarge;

  /// Toolbar height.
  final double toolbarHeight;

  /// Title bar height.
  final double titleBarHeight;

  /// Sidebar width.
  final DlmRange sidebarWidth;

  /// Inspector width.
  final DlmRange inspectorWidth;

  /// These metrics adjusted for [density]. Heights never drop below
  /// [minHitTarget].
  DlmMetrics scaled(DlmDensity density) {
    if (density == DlmDensity.regular) return this;
    final f = density.factor;
    double height(double v) => math.max(minHitTarget, (v * f).roundToDouble());
    return DlmMetrics(
      spacing: spacing._scaled(f),
      radii: radii,
      controlHeightSmall: height(controlHeightSmall),
      controlHeight: height(controlHeight),
      controlHeightLarge: height(controlHeightLarge),
      rowHeight: height(rowHeight),
      minHitTarget: minHitTarget,
      borderWidth: borderWidth,
      focusRingWidth: focusRingWidth,
      focusRingOffset: focusRingOffset,
      iconSmall: iconSmall,
      icon: icon,
      iconLarge: iconLarge,
      toolbarHeight: toolbarHeight,
      titleBarHeight: titleBarHeight,
      sidebarWidth: sidebarWidth,
      inspectorWidth: inspectorWidth,
    );
  }

  @override
  List<Object?> get props => [
    spacing,
    radii,
    controlHeightSmall,
    controlHeight,
    controlHeightLarge,
    rowHeight,
    minHitTarget,
    borderWidth,
    focusRingWidth,
    focusRingOffset,
    iconSmall,
    icon,
    iconLarge,
    toolbarHeight,
    titleBarHeight,
    sidebarWidth,
    inspectorWidth,
  ];
}
