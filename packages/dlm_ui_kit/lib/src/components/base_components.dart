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
        padding: EdgeInsets.symmetric(horizontal: m.spacing.md),
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

  @override
  Widget icon(
    BuildContext context,
    DlmIconName name, {
    required double size,
    required Color color,
  }) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: DlmIconPainter(name, color)),
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
    final border = hasError
        ? c.danger
        : states.focused
        ? c.focusRing
        : c.border;
    return AnimatedContainer(
      duration: t.motion.fast,
      constraints: BoxConstraints(minHeight: m.controlHeight),
      padding: EdgeInsets.symmetric(
        horizontal: m.spacing.md,
        vertical: multiline ? m.spacing.sm : 0,
      ),
      decoration: BoxDecoration(
        color: states.disabled
            ? c.controlFillDisabled
            : (states.hovered && !states.focused
                  ? c.controlFillHover
                  : c.controlFill),
        borderRadius: BorderRadius.circular(m.radii.control),
        border: Border.all(
          color: border,
          width: states.focused || hasError ? m.focusRingWidth : m.borderWidth,
        ),
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
