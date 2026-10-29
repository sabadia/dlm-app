import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// Breeze-style controls: one-pixel frames that turn accent-coloured on hover
/// and focus, solid accent selection with white text, outlined switch knobs.
class BreezeComponents extends DlmBaseComponents {
  /// Creates the Breeze component set.
  const BreezeComponents();

  @override
  double get iconStrokeWidth => 1.25;

  Color _frame(DlmThemeData t, DlmStates s) {
    final c = t.colors;
    if (s.disabled) return c.textPrimary.withValues(alpha: 0.2);
    if (s.focused || s.focusVisible || s.hovered) return c.accent;
    return t.colors.highContrast
        ? c.border
        : c.textPrimary.withValues(alpha: 0.2);
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
    final m = t.metrics;
    Color fill;
    Color text;
    Color frame;
    switch (variant) {
      case DlmButtonVariant.primary:
        fill = states.disabled
            ? c.controlFillDisabled
            : feedback(c.accent, states, dark: false);
        text = states.disabled ? c.textDisabled : c.textOnAccent;
        frame = fill;
      case DlmButtonVariant.destructive:
        fill = states.disabled
            ? c.controlFillDisabled
            : feedback(c.danger, states, dark: false);
        text = states.disabled ? c.textDisabled : onColor(c.danger);
        frame = fill;
      case DlmButtonVariant.secondary:
        fill = states.disabled
            ? c.controlFillDisabled
            : states.pressed
            ? c.controlFillPressed
            : c.controlFill;
        text = states.disabled ? c.textDisabled : c.textPrimary;
        frame = _frame(t, states);
      case DlmButtonVariant.plain:
        fill = states.pressed
            ? c.controlFillPressed
            : states.hovered
            ? c.rowHover
            : const Color(0x00000000);
        text = states.disabled ? c.textDisabled : c.textPrimary;
        frame = states.hovered ? c.accent : const Color(0x00000000);
    }
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: AnimatedContainer(
        duration: t.motion.fast,
        height: heightOf(m, size),
        padding: square
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: m.spacing.lg),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.radii.control),
          border: Border.all(color: frame),
        ),
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
    const width = 38.0;
    const height = 20.0;
    final active = states.disabled ? c.textDisabled : c.accent;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: height / 2,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: width,
        height: height,
        padding: const EdgeInsets.all(2),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? active : c.controlFill,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: value ? active : _frame(t, states)),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value
                ? c.textOnAccent
                : (states.disabled ? c.textDisabled : c.textSecondary),
          ),
          child: const SizedBox.square(dimension: 14),
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
    final mark = states.disabled ? c.textDisabled : c.textOnAccent;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: 3,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: filled && !states.disabled ? c.accent : c.controlFill,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: _frame(t, states)),
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
          color: c.controlFill,
          border: Border.all(
            color: selected && !states.disabled ? c.accent : _frame(t, states),
          ),
        ),
        child: selected
            ? DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: states.disabled ? c.textDisabled : c.accent,
                ),
                child: const SizedBox.square(dimension: 8),
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
    return AnimatedContainer(
      duration: t.motion.fast,
      constraints: BoxConstraints(minHeight: m.controlHeight),
      padding: EdgeInsets.symmetric(
        horizontal: m.spacing.md,
        vertical: multiline ? m.spacing.sm : 0,
      ),
      decoration: BoxDecoration(
        color: states.disabled ? c.controlFillDisabled : c.content,
        borderRadius: BorderRadius.circular(m.radii.control),
        border: Border.all(
          color: hasError ? c.danger : _frame(t, states),
          width: states.focused ? 2 : 1,
        ),
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
      child: AnimatedContainer(
        duration: t.motion.fast,
        constraints: BoxConstraints(minHeight: m.controlHeight),
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        decoration: BoxDecoration(
          color: states.disabled
              ? c.controlFillDisabled
              : (states.pressed ? c.controlFillPressed : c.controlFill),
          borderRadius: BorderRadius.circular(m.radii.control),
          border: Border.all(color: _frame(t, states)),
        ),
        child: content,
      ),
    );
  }

  Widget _selectable(
    BuildContext context,
    DlmStates states,
    Widget content,
    TextStyle base, {
    required double height,
    required Border? border,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final solid = states.selected && states.focused;
    final fill = solid
        ? c.accent
        : states.selected
        ? c.accent.withValues(alpha: 0.28)
        : states.hovered
        ? c.accent.withValues(alpha: 0.12)
        : const Color(0x00000000);
    final text = solid ? c.textOnAccent : c.textPrimary;
    return DlmFocusRing(
      visible: states.focusVisible && !solid,
      radius: t.metrics.radii.small,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: t.metrics.spacing.sm),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(t.metrics.radii.small),
          border: border,
        ),
        child: DefaultTextStyle.merge(
          style: base.copyWith(color: text),
          child: IconTheme.merge(
            data: IconThemeData(color: text, size: t.metrics.icon),
            child: content,
          ),
        ),
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
    return _selectable(
      context,
      // A sidebar selection stays solid while the sidebar is in use.
      states.selected ? states.copyWith(focused: true) : states,
      content,
      t.typography.body,
      height: t.metrics.controlHeight,
      border: null,
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
    final solid = states.selected && states.focused;
    return DlmFocusRing(
      visible: states.focusVisible && !solid,
      radius: t.metrics.radii.small,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: solid
              ? c.accent
              : states.selected
              ? c.accent.withValues(alpha: 0.28)
              : states.hovered
              ? c.accent.withValues(alpha: 0.1)
              : (odd
                    ? c.textPrimary.withValues(alpha: 0.03)
                    : const Color(0x00000000)),
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.body.copyWith(
            color: solid ? c.textOnAccent : c.textPrimary,
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              color: solid ? c.textOnAccent : c.textSecondary,
              size: t.metrics.icon,
            ),
            child: content,
          ),
        ),
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
    final selected = states.selected;
    final text = states.disabled
        ? c.textDisabled
        : selected
        ? c.textOnAccent
        : c.textPrimary;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: AnimatedContainer(
        duration: t.motion.fast,
        height: m.controlHeight,
        padding: EdgeInsets.symmetric(horizontal: m.spacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? c.accent
              : (states.hovered ? c.rowHover : const Color(0x00000000)),
          border: Border(
            right: isLast ? BorderSide.none : BorderSide(color: c.separator),
          ),
        ),
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
        padding: EdgeInsets.symmetric(horizontal: m.spacing.lg),
        decoration: BoxDecoration(
          color: states.selected
              ? c.content
              : (states.hovered ? c.rowHover : const Color(0x00000000)),
          border: Border(
            top: BorderSide(
              color: states.selected ? c.accent : const Color(0x00000000),
              width: 3,
            ),
          ),
        ),
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
  Widget slider(
    BuildContext context, {
    required double fraction,
    required double width,
    required double thumbRadius,
    required DlmStates states,
  }) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    const trackHeight = 4.0;
    final usable = width - thumbRadius * 2;
    final x = thumbRadius + usable * fraction.clamp(0, 1);
    final active = states.disabled ? c.textDisabled : c.accent;
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
                color: c.controlFill,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: c.textPrimary.withValues(alpha: 0.25),
                ),
              ),
              child: const SizedBox(height: trackHeight + 2),
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
              child: const SizedBox(height: trackHeight + 2),
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
                  color: c.controlFill,
                  border: Border.all(
                    color: states.hovered || states.pressed
                        ? c.accent
                        : _frame(t, states),
                    width: states.hovered || states.pressed ? 2 : 1,
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
}
