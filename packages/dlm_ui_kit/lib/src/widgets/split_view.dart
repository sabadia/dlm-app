import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/states.dart';
import '../theme/theme.dart';

class _ResizeIntent extends Intent {
  const _ResizeIntent(this.delta);
  final double delta;
}

class _JumpIntent extends Intent {
  const _JumpIntent({required this.toMax});
  final bool toMax;
}

/// Two panes with a draggable divider. The size of the [primary] pane is held
/// by the caller ([primarySize] / [onResized]) so it can be persisted. The
/// divider is a keyboard-operable separator: arrows move it by 16 px, Home and
/// End jump to the limits; double-click resets to [initialSize].
class DlmSplitView extends StatefulWidget {
  /// Creates a split view.
  const DlmSplitView({
    required this.primary,
    required this.secondary,
    required this.primarySize,
    required this.onResized,
    required this.dividerLabel,
    this.axis = Axis.horizontal,
    this.minPrimary = 160,
    this.minSecondary = 240,
    this.initialSize,
    this.primaryAtEnd = false,
    super.key,
  });

  /// The pane whose size is controlled.
  final Widget primary;

  /// The pane that takes the remaining space.
  final Widget secondary;

  /// Current size of the primary pane along [axis].
  final double primarySize;

  /// Called with the new size while dragging.
  final ValueChanged<double> onResized;

  /// Accessible name of the divider (localised): "Resize sidebar".
  final String dividerLabel;

  /// [Axis.horizontal] puts the panes side by side.
  final Axis axis;

  /// Smallest size of the primary pane.
  final double minPrimary;

  /// Smallest size of the secondary pane.
  final double minSecondary;

  /// Size restored by a double click on the divider.
  final double? initialSize;

  /// Put the primary pane after the secondary one (an inspector on the right).
  final bool primaryAtEnd;

  @override
  State<DlmSplitView> createState() => _DlmSplitViewState();
}

class _DlmSplitViewState extends State<DlmSplitView> {
  bool _hovered = false;
  bool _focused = false;
  bool _dragging = false;

  double _clamp(double v, double total) {
    final max = (total - widget.minSecondary).clamp(widget.minPrimary, total);
    return v.clamp(widget.minPrimary, max);
  }

  void _set(double v, double total) {
    final next = _clamp(v, total);
    if (next != widget.primarySize) widget.onResized(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final horizontal = widget.axis == Axis.horizontal;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // +1 along the axis grows the primary pane.
    final sign = widget.primaryAtEnd ? -1.0 : 1.0;
    final flip = horizontal && rtl ? -1.0 : 1.0;
    return LayoutBuilder(
      builder: (context, box) {
        final total = horizontal ? box.maxWidth : box.maxHeight;
        final size = _clamp(widget.primarySize, total);
        final divider = Semantics(
          container: true,
          label: widget.dividerLabel,
          value: '${size.round()}',
          increasedValue: '${_clamp(size + 16, total).round()}',
          decreasedValue: '${_clamp(size - 16, total).round()}',
          onIncrease: () => _set(size + 16, total),
          onDecrease: () => _set(size - 16, total),
          child: FocusableActionDetector(
            descendantsAreFocusable: false,
            descendantsAreTraversable: false,
            mouseCursor: horizontal
                ? SystemMouseCursors.resizeColumn
                : SystemMouseCursors.resizeRow,
            shortcuts: {
              SingleActivator(
                horizontal
                    ? LogicalKeyboardKey.arrowRight
                    : LogicalKeyboardKey.arrowDown,
              ): _ResizeIntent(
                16 * sign * flip,
              ),
              SingleActivator(
                horizontal
                    ? LogicalKeyboardKey.arrowLeft
                    : LogicalKeyboardKey.arrowUp,
              ): _ResizeIntent(
                -16 * sign * flip,
              ),
              const SingleActivator(LogicalKeyboardKey.home): _JumpIntent(
                toMax: widget.primaryAtEnd,
              ),
              const SingleActivator(LogicalKeyboardKey.end): _JumpIntent(
                toMax: !widget.primaryAtEnd,
              ),
            },
            actions: {
              _ResizeIntent: CallbackAction<_ResizeIntent>(
                onInvoke: (i) {
                  _set(size + i.delta, total);
                  return null;
                },
              ),
              _JumpIntent: CallbackAction<_JumpIntent>(
                onInvoke: (i) {
                  _set(i.toMax ? total : 0, total);
                  return null;
                },
              ),
            },
            onShowHoverHighlight: (v) => setState(() => _hovered = v),
            onShowFocusHighlight: (v) => setState(() => _focused = v),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: widget.initialSize == null
                  ? null
                  : () => _set(widget.initialSize!, total),
              onHorizontalDragStart: horizontal
                  ? (_) => setState(() => _dragging = true)
                  : null,
              onHorizontalDragUpdate: horizontal
                  ? (d) => _set(size + d.delta.dx * sign * flip, total)
                  : null,
              onHorizontalDragEnd: horizontal
                  ? (_) => setState(() => _dragging = false)
                  : null,
              onVerticalDragStart: horizontal
                  ? null
                  : (_) => setState(() => _dragging = true),
              onVerticalDragUpdate: horizontal
                  ? null
                  : (d) => _set(size + d.delta.dy * sign, total),
              onVerticalDragEnd: horizontal
                  ? null
                  : (_) => setState(() => _dragging = false),
              child: theme.components.splitDivider(
                context,
                axis: widget.axis,
                states: DlmStates(
                  hovered: _hovered,
                  pressed: _dragging,
                  focused: _focused,
                  focusVisible: _focused,
                ),
              ),
            ),
          ),
        );
        final primary = SizedBox(
          width: horizontal ? size : null,
          height: horizontal ? null : size,
          child: widget.primary,
        );
        final children = widget.primaryAtEnd
            ? [Expanded(child: widget.secondary), divider, primary]
            : [primary, divider, Expanded(child: widget.secondary)];
        return horizontal
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }
}
