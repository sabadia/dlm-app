import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// Fluent-style controls: subtle elevation on the bottom edge of buttons,
/// outlined unchecked controls, a text field whose bottom edge turns into a
/// two-pixel accent line on focus, and an accent pill beside the selected
/// navigation item.
class FluentComponents extends DlmBaseComponents {
  /// Creates the Fluent component set.
  const FluentComponents();

  /// A box with a uniform one-pixel outline and a separate, possibly thicker
  /// bottom edge. (Flutter cannot round the corners of a border whose sides
  /// differ, so the bottom edge is a line inside a clipped box.)
  Widget _framed({
    required DlmThemeData t,
    required Color fill,
    required Color edge,
    required Color bottom,
    required Widget child,
    required double radius,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double bottomWidth = 1,
    double? height,
    BoxConstraints? constraints,
  }) {
    return AnimatedContainer(
      duration: t.motion.fast,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: edge),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius > 1 ? radius - 1 : 0),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Padding(padding: padding, child: child),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomWidth,
              child: ColoredBox(color: bottom),
            ),
          ],
        ),
      ),
    );
  }

  Color _edge(DlmThemeData t, {Color? tone, double alpha = 0.1}) =>
      (tone ?? t.colors.textPrimary).withValues(
        alpha: t.colors.highContrast ? 1 : alpha,
      );

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
    final m = t.metrics;
    final dark = t.brightness == Brightness.dark;
    Color fill;
    Color text;
    var edge = const Color(0x00000000);
    var bottom = const Color(0x00000000);
    if (states.disabled) {
      fill = variant == DlmButtonVariant.plain
          ? const Color(0x00000000)
          : c.textPrimary.withValues(alpha: 0.06);
      text = c.textDisabled;
      if (variant != DlmButtonVariant.plain) {
        edge = c.textPrimary.withValues(alpha: 0.06);
        bottom = edge;
      }
    } else {
      switch (variant) {
        case DlmButtonVariant.primary:
          fill = feedback(c.accent, states, dark: dark);
          text = c.textOnAccent;
          edge = _edge(t, tone: const Color(0xFF000000));
          bottom = _edge(t, tone: const Color(0xFF000000), alpha: 0.35);
        case DlmButtonVariant.destructive:
          fill = feedback(c.danger, states, dark: dark);
          text = onColor(c.danger);
          edge = _edge(t, tone: const Color(0xFF000000));
          bottom = _edge(t, tone: const Color(0xFF000000), alpha: 0.35);
        case DlmButtonVariant.secondary:
          fill = states.pressed
              ? c.controlFillPressed
              : states.hovered
              ? c.controlFillHover
              : c.controlFill;
          text = c.textPrimary;
          edge = _edge(t);
          bottom = _edge(t, alpha: 0.2);
        case DlmButtonVariant.plain:
          fill = states.pressed
              ? c.controlFillPressed
              : states.hovered
              ? c.rowHover
              : const Color(0x00000000);
          text = c.textPrimary;
      }
    }
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: _framed(
        t: t,
        fill: fill,
        edge: edge,
        bottom: bottom,
        radius: m.radii.control,
        height: heightOf(m, size),
        padding: square
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: m.spacing.lg),
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
  Widget switchControl(
    BuildContext context, {
    required bool value,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    const width = 40.0;
    const height = 20.0;
    final accent = states.disabled
        ? c.textDisabled
        : feedback(c.accent, states, dark: false);
    final outline = states.disabled
        ? c.textDisabled
        : c.textPrimary.withValues(alpha: 0.6);
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: height / 2,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value
              ? accent
              : (states.hovered ? c.controlFillHover : const Color(0x00000000)),
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: value ? accent : outline),
        ),
        child: AnimatedContainer(
          duration: t.motion.fast,
          width: states.pressed ? 16 : (states.hovered ? 14 : 12),
          height: states.pressed ? 16 : (states.hovered ? 14 : 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? c.textOnAccent : outline,
          ),
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
    final filled = value != DlmCheckState.unchecked;
    final fill = states.disabled
        ? const Color(0x00000000)
        : filled
        ? feedback(c.accent, states, dark: false)
        : (states.hovered ? c.controlFillHover : const Color(0x00000000));
    final mark = states.disabled ? c.textDisabled : c.textOnAccent;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: 4,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(4),
          border: filled && !states.disabled
              ? null
              : Border.all(
                  color: states.disabled
                      ? c.textDisabled
                      : c.textPrimary.withValues(alpha: 0.6),
                ),
        ),
        child: switch (value) {
          DlmCheckState.unchecked => null,
          DlmCheckState.checked => CustomPaint(
            painter: DlmIconPainter(DlmIconName.check, mark),
          ),
          DlmCheckState.mixed => CustomPaint(
            painter: DlmIconPainter(DlmIconName.minus, mark),
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
    final accent = states.disabled
        ? c.textDisabled
        : feedback(c.accent, states, dark: false);
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: 10,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? accent : const Color(0x00000000),
          border: Border.all(
            color: selected
                ? accent
                : (states.disabled
                      ? c.textDisabled
                      : c.textPrimary.withValues(alpha: 0.6)),
          ),
        ),
        child: selected
            ? AnimatedContainer(
                duration: t.motion.fast,
                width: states.pressed ? 8 : 10,
                height: states.pressed ? 8 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.textOnAccent,
                ),
              )
            : null,
      ),
    );
  }

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
    final edge = states.disabled
        ? c.textPrimary.withValues(alpha: 0.06)
        : _edge(t, alpha: 0.12);
    final bottom = hasError
        ? c.danger
        : states.focused
        ? c.accent
        : _edge(t, alpha: 0.5);
    return _framed(
      t: t,
      fill: states.disabled
          ? c.controlFillDisabled
          : (states.focused
                ? c.content
                : (states.hovered ? c.controlFillHover : c.controlFill)),
      edge: edge,
      bottom: bottom,
      bottomWidth: states.focused || hasError ? 2 : 1,
      radius: m.radii.control,
      constraints: BoxConstraints(minHeight: m.controlHeight),
      padding: EdgeInsets.symmetric(
        horizontal: m.spacing.md,
        vertical: multiline ? m.spacing.sm : 0,
      ),
      child: child,
    );
  }

  @override
  Widget dropdownTrigger(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: _framed(
        t: t,
        fill: states.disabled
            ? c.controlFillDisabled
            : (states.pressed
                  ? c.controlFillPressed
                  : (states.hovered ? c.controlFillHover : c.controlFill)),
        edge: _edge(t),
        bottom: _edge(t, alpha: 0.2),
        radius: m.radii.control,
        constraints: BoxConstraints(minHeight: m.controlHeight),
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        child: content,
      ),
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
    final text = states.disabled ? c.textDisabled : c.textPrimary;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: m.controlHeight + 4,
            padding: EdgeInsets.only(
              left: m.spacing.md + 2,
              right: m.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: states.selected
                  ? c.textPrimary.withValues(alpha: 0.07)
                  : (states.hovered
                        ? c.textPrimary.withValues(alpha: 0.04)
                        : const Color(0x00000000)),
              borderRadius: BorderRadius.circular(m.radii.control),
            ),
            child: DefaultTextStyle.merge(
              style: t.typography.body.copyWith(color: text),
              child: IconTheme.merge(
                data: IconThemeData(color: text, size: m.icon),
                child: content,
              ),
            ),
          ),
          if (states.selected)
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox(width: 3, height: 16),
            ),
        ],
      ),
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
    final usable = width - thumbRadius * 2;
    final x = thumbRadius + usable * fraction.clamp(0, 1);
    final active = states.disabled ? c.textDisabled : c.accent;
    final inner = states.pressed ? 8.0 : (states.hovered ? 14.0 : 12.0);
    return SizedBox(
      width: width,
      height: t.metrics.controlHeight,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: thumbRadius,
            right: thumbRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.textPrimary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox(height: 4),
            ),
          ),
          Positioned(
            left: thumbRadius,
            width: x - thumbRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: active,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox(height: 4),
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
                  color: c.overlay,
                  border: Border.all(
                    color: c.textPrimary.withValues(alpha: 0.15),
                  ),
                ),
                child: SizedBox.square(
                  dimension: thumbRadius * 2,
                  child: Center(
                    child: AnimatedContainer(
                      duration: t.motion.fast,
                      width: inner,
                      height: inner,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
