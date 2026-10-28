import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// libadwaita-style controls: flat and borderless, tinted from the text colour
/// (8 % at rest, 12 % hovered, 16 % pressed), accent fills for the suggested
/// action, round knobs and "linked" segmented buttons.
class AdwaitaComponents extends DlmBaseComponents {
  /// Creates the Adwaita component set.
  const AdwaitaComponents();

  Color _tint(DlmThemeData t, DlmStates s, {double rest = 0.08}) {
    final a = s.pressed ? rest * 2 : (s.hovered ? rest * 1.5 : rest);
    return t.colors.textPrimary.withValues(alpha: a);
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
    if (states.disabled) {
      fill = variant == DlmButtonVariant.plain
          ? const Color(0x00000000)
          : c.textPrimary.withValues(alpha: 0.05);
      text = c.textDisabled;
    } else {
      switch (variant) {
        case DlmButtonVariant.primary:
          fill = feedback(c.accent, states, dark: false);
          text = c.textOnAccent;
        case DlmButtonVariant.destructive:
          fill = feedback(c.danger, states, dark: false);
          text = onColor(c.danger);
        case DlmButtonVariant.secondary:
          fill = _tint(t, states);
          text = c.textPrimary;
        case DlmButtonVariant.plain:
          fill = states.hovered || states.pressed
              ? _tint(t, states, rest: 0.0001)
              : const Color(0x00000000);
          text = c.textPrimary;
      }
    }
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: AnimatedContainer(
        duration: t.motion.fast,
        height: heightOf(m, size),
        padding: square
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: m.spacing.md + 2),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.radii.control),
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.label.copyWith(
            color: text,
            fontWeight: FontWeight.w600,
          ),
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
    const width = 46.0;
    const height = 26.0;
    final track = states.disabled
        ? c.textPrimary.withValues(alpha: 0.08)
        : value
        ? feedback(c.accent, states, dark: false)
        : _tint(t, states, rest: 0.12);
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: height / 2,
      child: AnimatedContainer(
        duration: t.motion.fast,
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
            shape: BoxShape.circle,
            color: states.disabled
                ? c.textPrimary.withValues(alpha: 0.2)
                : const Color(0xFFFFFFFF),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: const SizedBox.square(dimension: 20),
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
        ? c.textPrimary.withValues(alpha: 0.06)
        : filled
        ? feedback(c.accent, states, dark: false)
        : _tint(t, states, rest: 0.1);
    final mark = states.disabled ? c.textDisabled : c.textOnAccent;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: 6,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(6),
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
    final fill = states.disabled
        ? c.textPrimary.withValues(alpha: 0.06)
        : selected
        ? feedback(c.accent, states, dark: false)
        : _tint(t, states, rest: 0.1);
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: 11,
      child: AnimatedContainer(
        duration: t.motion.fast,
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
        child: selected
            ? DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: states.disabled ? c.textDisabled : c.textOnAccent,
                ),
                child: const SizedBox.square(dimension: 8),
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
        color: t.colors.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.metrics.radii.control + 2),
      ),
      child: Padding(padding: const EdgeInsets.all(3), child: child),
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
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: AnimatedContainer(
        duration: t.motion.fast,
        height: m.controlHeight - 6,
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        decoration: BoxDecoration(
          color: selected
              ? c.content
              : (states.hovered
                    ? c.textPrimary.withValues(alpha: 0.06)
                    : const Color(0x00000000)),
          borderRadius: BorderRadius.circular(m.radii.control),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.label.copyWith(
            color: states.disabled ? c.textDisabled : c.textPrimary,
            fontWeight: selected ? FontWeight.w600 : null,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: c.textPrimary, size: m.icon),
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
    final text = states.disabled ? c.textDisabled : c.textPrimary;
    return DlmFocusRing(
      visible: states.focusVisible,
      radius: m.radii.control,
      child: Container(
        height: m.controlHeight,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        decoration: BoxDecoration(
          color: states.selected
              ? c.textPrimary.withValues(alpha: 0.1)
              : (states.hovered
                    ? c.textPrimary.withValues(alpha: 0.06)
                    : const Color(0x00000000)),
          borderRadius: BorderRadius.circular(m.radii.control),
        ),
        child: DefaultTextStyle.merge(
          style: t.typography.label.copyWith(
            color: text,
            fontWeight: states.selected ? FontWeight.w600 : null,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: text, size: m.icon),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
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
    final ring = hasError
        ? c.danger
        : states.focused
        ? c.accent
        : const Color(0x00000000);
    return AnimatedContainer(
      duration: t.motion.fast,
      constraints: BoxConstraints(minHeight: m.controlHeight),
      padding: EdgeInsets.symmetric(
        horizontal: m.spacing.md,
        vertical: multiline ? m.spacing.sm : 0,
      ),
      decoration: BoxDecoration(
        color: states.disabled
            ? c.textPrimary.withValues(alpha: 0.04)
            : c.textPrimary.withValues(alpha: states.hovered ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(m.radii.control),
        border: Border.all(color: ring, width: 2),
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
              ? c.textPrimary.withValues(alpha: 0.05)
              : _tint(t, states),
          borderRadius: BorderRadius.circular(m.radii.control),
        ),
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
      child: Container(
        height: m.controlHeight + 2,
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
        decoration: BoxDecoration(
          color: states.selected
              ? c.textPrimary.withValues(alpha: 0.1)
              : (states.hovered
                    ? c.textPrimary.withValues(alpha: 0.06)
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
    );
  }

  @override
  Widget toolbar(BuildContext context, {required Widget child}) {
    final t = DlmTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.sidebar,
        border: Border(bottom: BorderSide(color: t.colors.separator)),
      ),
      child: SizedBox(
        height: t.metrics.toolbarHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: t.metrics.spacing.sm),
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
            padding: EdgeInsets.only(left: m.spacing.xs, bottom: m.spacing.sm),
            child: DefaultTextStyle.merge(
              style: t.typography.subtitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
              child: title,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.raised,
            borderRadius: BorderRadius.circular(m.radii.container),
            border: Border.all(color: c.textPrimary.withValues(alpha: 0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(m.radii.container),
            child: rows,
          ),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.only(left: m.spacing.xs, top: m.spacing.sm),
            child: DefaultTextStyle.merge(
              style: t.typography.caption.copyWith(color: c.textSecondary),
              child: footer,
            ),
          ),
      ],
    );
  }
}
