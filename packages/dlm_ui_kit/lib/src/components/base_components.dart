import 'package:flutter/widgets.dart';

import '../behavior/focus_ring.dart';
import '../behavior/states.dart';
import '../theme/colors.dart';
import '../theme/contrast.dart';
import '../theme/metrics.dart';
import '../theme/theme.dart';
import 'components.dart';
import 'icon_painter.dart';

/// Draws every component from the theme's tokens. Skins extend this and
/// override the builders they draw differently.
class DlmBaseComponents extends DlmComponents {
  /// Creates the token-driven component set.
  const DlmBaseComponents();

  /// Height of a control of [size].
  @protected
  double heightOf(DlmMetrics m, DlmControlSize size) => switch (size) {
    DlmControlSize.small => m.controlHeightSmall,
    DlmControlSize.regular => m.controlHeight,
    DlmControlSize.large => m.controlHeightLarge,
  };

  /// [color] darkened or lightened for hover/pressed feedback.
  @protected
  Color feedback(Color color, DlmStates states, {required bool dark}) {
    if (states.disabled) return color;
    final amount = states.pressed ? 0.16 : (states.hovered ? 0.08 : 0.0);
    if (amount == 0) return color;
    return Color.alphaBlend(
      (dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000)).withValues(
        alpha: amount,
      ),
      color,
    );
  }

  @override
  Widget button(
    BuildContext context, {
    required DlmButtonVariant variant,
    required DlmControlSize size,
    required DlmStates states,
    required Widget content,
    bool square = false,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final dark = t.brightness == Brightness.dark;
    final (fill, textColor, border) = _buttonColors(c, variant, states, dark);
    final m = t.metrics;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: AnimatedContainer(
        duration: t.motion.fast,
        curve: t.motion.standard,
        height: heightOf(m, size),
        padding: square
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: m.spacing.md),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.radii.control),
          border: border == null
              ? null
              : Border.all(color: border, width: m.borderWidth),
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.label.copyWith(color: textColor),
          child: IconTheme.merge(
            data: IconThemeData(color: textColor, size: m.icon),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _buttonColors(
    DlmColors c,
    DlmButtonVariant variant,
    DlmStates states,
    bool dark,
  ) {
    if (states.disabled) {
      return switch (variant) {
        DlmButtonVariant.plain => (
          const Color(0x00000000),
          c.textDisabled,
          null,
        ),
        _ => (c.controlFillDisabled, c.textDisabled, null),
      };
    }
    switch (variant) {
      case DlmButtonVariant.primary:
        return (feedback(c.accent, states, dark: false), c.textOnAccent, null);
      case DlmButtonVariant.destructive:
        final fill = feedback(c.danger, states, dark: false);
        return (fill, onColor(c.danger), null);
      case DlmButtonVariant.secondary:
        final fill = states.pressed
            ? c.controlFillPressed
            : (states.hovered ? c.controlFillHover : c.controlFill);
        return (fill, c.textPrimary, c.border);
      case DlmButtonVariant.plain:
        final fill = states.pressed
            ? c.controlFillPressed
            : (states.hovered ? c.rowHover : const Color(0x00000000));
        return (fill, c.textLink, null);
    }
  }

  @override
  Widget switchControl(
    BuildContext context, {
    required bool value,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final height = m.icon + 6;
    final width = height * 1.8;
    final track = states.disabled
        ? c.controlFillDisabled
        : value
        ? feedback(c.accent, states, dark: false)
        : feedback(c.border, states, dark: t.brightness == Brightness.dark);
    final thumb = value ? c.textOnAccent : c.content;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: height / 2,
      child: AnimatedContainer(
        duration: t.motion.fast,
        curve: t.motion.standard,
        width: width,
        height: height,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: track,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: states.disabled ? c.textDisabled : thumb,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(dimension: height - 6),
        ),
      ),
    );
  }

  @override
  Widget checkbox(
    BuildContext context, {
    required DlmCheckState value,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final filled = value != DlmCheckState.unchecked;
    final fill = states.disabled
        ? c.controlFillDisabled
        : filled
        ? feedback(c.accent, states, dark: false)
        : (states.hovered ? c.controlFillHover : c.controlFill);
    final mark = states.disabled ? c.textDisabled : c.textOnAccent;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.small,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: m.icon + 2,
        height: m.icon + 2,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.radii.small),
          border: filled && !states.disabled
              ? null
              : Border.all(color: c.border, width: m.borderWidth),
        ),
        child: switch (value) {
          DlmCheckState.unchecked => null,
          DlmCheckState.checked => CustomPaint(painter: _MarkPainter(mark)),
          DlmCheckState.mixed => CustomPaint(
            painter: _MarkPainter(mark, dash: true),
          ),
        },
      ),
    );
  }

  @override
  Widget radio(
    BuildContext context, {
    required bool selected,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final size = m.icon + 2;
    final ring = states.disabled
        ? c.textDisabled
        : selected
        ? c.accent
        : c.border;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: size / 2,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: states.hovered && !selected
              ? c.controlFillHover
              : c.controlFill,
          border: Border.all(
            color: ring,
            width: selected ? m.borderWidth * 2 : m.borderWidth,
          ),
        ),
        child: selected
            ? DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
                child: SizedBox.square(dimension: size / 2.4),
              )
            : null,
      ),
    );
  }

  @override
  Widget segmentedFrame(BuildContext context, {required Widget child}) {
    final t = DlmTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.controlFill,
        borderRadius: BorderRadius.circular(t.metrics.radii.control),
        border: Border.all(
          color: t.colors.border,
          width: t.metrics.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t.metrics.radii.control),
        child: child,
      ),
    );
  }

  @override
  Widget segment(
    BuildContext context, {
    required bool isFirst,
    required bool isLast,
    required DlmStates states,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final fill = states.selected
        ? c.accent
        : states.pressed
        ? c.controlFillPressed
        : states.hovered
        ? c.controlFillHover
        : const Color(0x00000000);
    final text = states.disabled
        ? c.textDisabled
        : states.selected
        ? c.textOnAccent
        : c.textPrimary;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: AnimatedContainer(
        duration: t.motion.fast,
        height: m.controlHeight,
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        color: fill,
        child: DefaultTextStyle.merge(
          style: t.typography.label.copyWith(color: text),
          child: IconTheme.merge(
            data: IconThemeData(color: text, size: m.icon),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
  }

  @override
  Widget tab(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final text = states.disabled
        ? c.textDisabled
        : states.selected
        ? c.textPrimary
        : c.textSecondary;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.small,
      child: Container(
        height: m.controlHeight,
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        decoration: BoxDecoration(
          color: states.hovered && !states.selected
              ? c.rowHover
              : const Color(0x00000000),
          border: Border(
            bottom: BorderSide(
              color: states.selected ? c.accent : const Color(0x00000000),
              width: m.focusRingWidth,
            ),
          ),
        ),
        child: DefaultTextStyle.merge(
          style:
              (states.selected ? t.typography.bodyStrong : t.typography.label)
                  .copyWith(color: text),
          child: IconTheme.merge(
            data: IconThemeData(color: text, size: m.icon),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
  }

  /// Stroke width of the built-in glyphs on their 16 x 16 grid; skins change
  /// it to match their icon weight.
  @protected
  double get iconStrokeWidth => 1.5;

  @override
  Widget icon(
    BuildContext context,
    DlmIconName name, {
    required double size,
    required Color color,
  }) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: DlmIconPainter(name, color, strokeWidth: iconStrokeWidth),
    ),
  );

  @override
  Widget textFieldFrame(
    BuildContext context, {
    required DlmStates states,
    required bool hasError,
    required bool multiline,
    required Widget child,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    // Filled and borderless until focused: a soft ring and glow, not a hard
    // outline. High contrast keeps a visible border.
    final idle = c.highContrast ? c.border : const Color(0x00000000);
    final border = hasError
        ? c.danger
        : states.focused
        ? c.focusRing
        : idle;
    final fill = states.disabled
        ? c.controlFillDisabled
        : Color.alphaBlend(
            c.textPrimary.withValues(
              alpha: states.focused ? 0.03 : (states.hovered ? 0.085 : 0.06),
            ),
            c.content,
          );
    return AnimatedContainer(
      duration: t.motion.fast,
      constraints: BoxConstraints(minHeight: m.controlHeight),
      padding: EdgeInsets.symmetric(
        horizontal: m.spacing.md,
        vertical: multiline ? m.spacing.sm : 0,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(m.radii.control),
        border: Border.all(
          color: border,
          width: states.focused || hasError
              ? m.focusRingWidth
              : (c.highContrast ? m.borderWidth : 0),
        ),
        boxShadow: states.focused && !hasError && !c.highContrast
            ? [
                BoxShadow(
                  color: c.focusRing.withValues(alpha: 0.22),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  Widget slider(
    BuildContext context, {
    required double fraction,
    required double width,
    required double thumbRadius,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    const trackHeight = 4.0;
    final usable = width - thumbRadius * 2;
    final x = thumbRadius + usable * fraction.clamp(0, 1);
    final active = states.disabled ? c.textDisabled : c.accent;
    return SizedBox(
      width: width,
      height: m.controlHeight,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: thumbRadius,
            right: thumbRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(trackHeight),
              ),
              child: const SizedBox(height: trackHeight),
            ),
          ),
          Positioned(
            left: thumbRadius,
            width: x - thumbRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: active,
                borderRadius: BorderRadius.circular(trackHeight),
              ),
              child: const SizedBox(height: trackHeight),
            ),
          ),
          Positioned(
            left: x - thumbRadius,
            child: DlmFocusRing(
              visible: states.focusVisible,
              radius: thumbRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: states.disabled ? c.controlFillDisabled : c.content,
                  border: Border.all(
                    color: active,
                    width: states.pressed ? thumbRadius / 2 : m.focusRingWidth,
                  ),
                ),
                child: SizedBox.square(dimension: thumbRadius * 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The colour of [tone].
  @protected
  Color toneColor(DlmColors c, DlmTone tone) => switch (tone) {
    DlmTone.neutral => c.textSecondary,
    DlmTone.accent => c.accent,
    DlmTone.success => c.success,
    DlmTone.warning => c.warning,
    DlmTone.danger => c.danger,
    DlmTone.info => c.info,
  };

  @override
  Widget progressBar(
    BuildContext context, {
    required double? value,
    required double phase,
    required DlmTone tone,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final color = tone == DlmTone.neutral ? c.accent : toneColor(c, tone);
    const height = 6.0;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.border.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(height),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final double left;
            final double width;
            if (value == null) {
              width = w * 0.3;
              left = (w + width) * phase - width;
            } else {
              width = w * value.clamp(0, 1);
              left = 0;
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(height),
              child: Stack(
                children: [
                  Positioned(
                    left: left,
                    width: width,
                    top: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(height),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget progressRing(
    BuildContext context, {
    required double? value,
    required double phase,
    required DlmTone tone,
    required double size,
  }) {
    final c = DlmTheme.of(context).colors;
    final color = tone == DlmTone.neutral ? c.accent : toneColor(c, tone);
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value,
          phase: phase,
          color: color,
          track: c.border.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  @override
  Widget badge(
    BuildContext context, {
    required DlmTone tone,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final bg = tone == DlmTone.neutral
        ? c.controlFillHover
        : Color.alphaBlend(
            toneColor(c, tone).withValues(alpha: 0.16),
            c.content,
          );
    final fg = tone == DlmTone.neutral
        ? c.textSecondary
        : ensureContrast(toneColor(c, tone), bg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(m.radii.small + 6),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: m.spacing.sm,
          vertical: m.spacing.xxs,
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.caption.copyWith(color: fg),
          child: IconTheme.merge(
            data: IconThemeData(color: fg, size: m.iconSmall),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget chip(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final fill = states.selected
        ? c.accentSubtle
        : states.pressed
        ? c.controlFillPressed
        : states.hovered
        ? c.controlFillHover
        : c.controlFill;
    final text = states.disabled ? c.textDisabled : c.textPrimary;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.controlHeightSmall / 2,
      child: Container(
        height: m.controlHeightSmall,
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.controlHeightSmall / 2),
          border: Border.all(
            color: states.selected ? c.accent : c.border,
            width: m.borderWidth,
          ),
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.label.copyWith(color: text),
          child: IconTheme.merge(
            data: IconThemeData(color: text, size: m.iconSmall),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
  }

  @override
  Widget listRow(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final fill = states.selected
        ? (states.focused ? c.selection : c.selectionInactive)
        : states.hovered
        ? c.rowHover
        : const Color(0x00000000);
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: dlmSelectionSurface(
        context,
        fill: fill,
        radius: m.radii.control,
        edge: states.selected ? c.accent : null,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: Container(
          constraints: BoxConstraints(minHeight: m.rowHeight),
          padding: EdgeInsets.symmetric(
            horizontal: m.spacing.md,
            vertical: m.spacing.xs,
          ),
          child: DefaultTextStyle.merge(
            style: t.typography.body.copyWith(
              color: states.disabled ? c.textDisabled : c.textPrimary,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget banner(
    BuildContext context, {
    required DlmTone tone,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final color = toneColor(c, tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.12), c.content),
        borderRadius: BorderRadius.circular(m.radii.container),
        border: Border.all(color: color, width: m.borderWidth),
      ),
      child: Padding(
        padding: EdgeInsets.all(m.spacing.md),
        child: DefaultTextStyle.merge(
          style: t.typography.body.copyWith(color: c.textPrimary),
          child: IconTheme.merge(
            data: IconThemeData(color: color, size: m.icon),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget toast(
    BuildContext context, {
    required DlmTone tone,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final color = toneColor(c, tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.overlay,
        borderRadius: BorderRadius.circular(m.radii.container),
        border: Border.all(color: c.separator, width: m.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(m.spacing.md),
        child: DefaultTextStyle.merge(
          style: t.typography.body.copyWith(color: c.textPrimary),
          child: IconTheme.merge(
            data: IconThemeData(color: color, size: m.icon),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget tooltipBubble(BuildContext context, {required Widget content}) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.overlay,
        borderRadius: BorderRadius.circular(m.radii.small),
        border: Border.all(color: c.border, width: m.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: m.spacing.sm,
          vertical: m.spacing.xs,
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.caption.copyWith(color: c.textPrimary),
          child: content,
        ),
      ),
    );
  }

  Widget _floating(BuildContext context, Widget child, {double? pad}) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.overlay,
        borderRadius: BorderRadius.circular(m.radii.container),
        border: Border.all(color: c.separator, width: m.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(pad ?? m.spacing.xs),
        child: child,
      ),
    );
  }

  @override
  Widget popoverSurface(BuildContext context, {required Widget child}) =>
      _floating(context, child, pad: DlmTheme.of(context).metrics.spacing.md);

  @override
  Widget menuSurface(BuildContext context, {required Widget child}) =>
      _floating(context, child);

  @override
  Widget menuItem(
    BuildContext context, {
    required DlmStates states,
    required bool destructive,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final active = states.hovered || states.focusVisible || states.pressed;
    final fill = active
        ? (destructive ? c.danger : c.accent)
        : const Color(0x00000000);
    final text = states.disabled
        ? c.textDisabled
        : active
        ? onColor(fill)
        : (destructive ? c.danger : c.textPrimary);
    return Container(
      height: m.controlHeight,
      padding: EdgeInsets.symmetric(horizontal: m.spacing.sm),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(m.radii.small),
      ),
      child: DefaultTextStyle.merge(
        style: t.typography.body.copyWith(color: text),
        child: IconTheme.merge(
          data: IconThemeData(color: text, size: m.icon),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget dropdownTrigger(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  }) => textFieldFrame(
    context,
    states: states,
    hasError: false,
    multiline: false,
    child: content,
  );

  @override
  Widget dialogSurface(
    BuildContext context, {
    required DlmDialogKind kind,
    required Widget child,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final radius = kind == DlmDialogKind.dialog
        ? BorderRadius.circular(m.radii.container)
        : BorderRadius.vertical(bottom: Radius.circular(m.radii.container));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.overlay,
        borderRadius: radius,
        border: Border.all(color: c.separator, width: m.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: EdgeInsets.all(m.spacing.xl), child: child),
    );
  }

  @override
  Widget sidebarSurface(BuildContext context, {required Widget child}) {
    final t = DlmTheme.of(context);
    final material = t.materials.sidebar;
    final color = material.isTranslucent
        ? t.colors.sidebar.withValues(alpha: material.tintOpacity)
        : t.colors.sidebar;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border(
          right: BorderSide(
            color: t.colors.separator,
            width: t.metrics.borderWidth,
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget sidebarItem(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final fill = states.selected
        ? c.selection
        : states.pressed
        ? c.controlFillPressed
        : states.hovered
        ? c.rowHover
        : const Color(0x00000000);
    final text = states.disabled ? c.textDisabled : c.textPrimary;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: dlmSelectionSurface(
        context,
        fill: fill,
        radius: m.radii.control,
        edge: states.selected ? c.accent : null,
        child: Container(
          height: m.controlHeight,
          padding: EdgeInsets.symmetric(horizontal: m.spacing.sm),
          child: DefaultTextStyle.merge(
            style:
                (states.selected ? t.typography.bodyStrong : t.typography.body)
                    .copyWith(color: text),
            child: IconTheme.merge(
              data: IconThemeData(
                color: states.selected ? c.accent : c.textSecondary,
                size: m.icon,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget toolbar(BuildContext context, {required Widget child}) {
    final t = DlmTheme.of(context);
    final material = t.materials.toolbar;
    final color = material.isTranslucent
        ? t.colors.window.withValues(alpha: material.tintOpacity)
        : t.colors.window;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border(
          bottom: BorderSide(
            color: t.colors.separator,
            width: t.metrics.borderWidth,
          ),
        ),
      ),
      child: SizedBox(
        height: t.metrics.toolbarHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: t.metrics.spacing.md),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget formGroup(
    BuildContext context, {
    required Widget rows,
    Widget? title,
    Widget? footer,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: m.spacing.xs, bottom: m.spacing.xs),
            child: DefaultTextStyle.merge(
              style: t.typography.subtitle,
              child: title,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.raised,
            borderRadius: BorderRadius.circular(m.radii.container),
            border: Border.all(color: c.separator, width: m.borderWidth),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(m.radii.container),
            child: rows,
          ),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.only(left: m.spacing.xs, top: m.spacing.xs),
            child: DefaultTextStyle.merge(
              style: t.typography.caption.copyWith(color: c.textSecondary),
              child: footer,
            ),
          ),
      ],
    );
  }

  @override
  Widget splitDivider(
    BuildContext context, {
    required Axis axis,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final active = states.hovered || states.pressed || states.focusVisible;
    final line = DecoratedBox(
      decoration: BoxDecoration(color: active ? c.accent : c.separator),
      child: SizedBox(
        width: axis == Axis.horizontal ? (active ? 2 : 1) : null,
        height: axis == Axis.vertical ? (active ? 2 : 1) : null,
      ),
    );
    // Opaque backing: with a transparent window background (a backdrop effect
    // behind the sidebar) an unpainted gap would show the desktop.
    return SizedBox(
      width: axis == Axis.horizontal ? 8 : null,
      height: axis == Axis.vertical ? 8 : null,
      child: ColoredBox(
        color: c.window,
        child: Center(child: line),
      ),
    );
  }

  @override
  Widget tableHeader(BuildContext context, {required Widget child}) {
    final t = DlmTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        border: Border(
          bottom: BorderSide(
            color: t.colors.separator,
            width: t.metrics.borderWidth,
          ),
        ),
      ),
      child: SizedBox(height: t.metrics.controlHeight, child: child),
    );
  }

  @override
  Widget tableHeaderCell(
    BuildContext context, {
    required DlmStates states,
    required bool? sorted,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.small,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: m.spacing.sm),
        alignment: Alignment.centerLeft,
        color: states.pressed
            ? c.controlFillPressed
            : (states.hovered ? c.controlFillHover : const Color(0x00000000)),
        child: DefaultTextStyle.merge(
          style: t.typography.label.copyWith(
            color: c.textSecondary,
            fontWeight: sorted == null ? null : FontWeight.w600,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: c.textSecondary, size: m.iconSmall),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget tableRow(
    BuildContext context, {
    required DlmStates states,
    required bool odd,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final fill = states.selected
        ? (states.focused ? c.selection : c.selectionInactive)
        : states.hovered
        ? c.rowHover
        : const Color(0x00000000);
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.small,
      child: dlmSelectionSurface(
        context,
        fill: fill,
        radius: m.radii.small,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: states.selected ? const Color(0x00000000) : c.separator,
                width: m.borderWidth,
              ),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: t.typography.body.copyWith(color: c.textPrimary),
            child: IconTheme.merge(
              data: IconThemeData(color: c.textSecondary, size: m.icon),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget scheduleCell(
    BuildContext context, {
    required bool on,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.small,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: on
              ? (states.hovered
                    ? feedback(c.accent, states, dark: false)
                    : c.accent)
              : (states.hovered ? c.controlFillHover : c.controlFill),
          border: Border.all(color: c.separator, width: m.borderWidth),
          borderRadius: BorderRadius.circular(m.radii.small / 2),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.phase,
    required this.color,
    required this.track,
  });

  final double? value;
  final double phase;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide / 8;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 6.2831853, false, base..color = track);
    final sweep = value == null
        ? 6.2831853 * 0.28
        : 6.2831853 * value!.clamp(0, 1);
    final start = value == null ? -1.5707963 + 6.2831853 * phase : -1.5707963;
    canvas.drawArc(rect, start, sweep, false, base..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.phase != phase ||
      old.color != color ||
      old.track != track;
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color, {this.dash = false});

  final Color color;
  final bool dash;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide / 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    if (dash) {
      path
        ..moveTo(size.width * 0.28, size.height / 2)
        ..lineTo(size.width * 0.72, size.height / 2);
    } else {
      path
        ..moveTo(size.width * 0.25, size.height * 0.52)
        ..lineTo(size.width * 0.42, size.height * 0.7)
        ..lineTo(size.width * 0.75, size.height * 0.32);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.color != color || old.dash != dash;
}

/// A row or item background: transparent, or a rounded tint, with a slim
/// accent edge on the leading side when [edge] is set.
Widget dlmSelectionSurface(
  BuildContext context, {
  required Color fill,
  required double radius,
  required Widget child,
  Color? edge,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
}) {
  final shape = BorderRadius.circular(radius);
  return Padding(
    padding: margin,
    child: DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: shape),
      child: edge == null
          ? child
          : Stack(
              children: [
                child,
                PositionedDirectional(
                  start: 0,
                  top: 8,
                  bottom: 8,
                  width: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: edge,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
}
