import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/states.dart';
import '../theme/theme.dart';

class _StepIntent extends Intent {
  const _StepIntent(this.steps);
  final double steps;
}

class _JumpIntent extends Intent {
  const _JumpIntent({required this.toEnd});
  final bool toEnd;
}

/// A horizontal slider for a value between [min] and [max], optionally in
/// [divisions] steps. Arrow keys move by one step (a tenth of the range
/// without divisions), Page Up/Down by ten steps, Home/End to the ends.
class DlmSlider extends StatefulWidget {
  /// Creates a slider; `onChanged: null` disables it.
  const DlmSlider({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.formatValue,
    this.onChangeEnd,
    super.key,
  }) : assert(max > min, 'max must be greater than min');

  /// The current value.
  final double value;

  /// Called continuously while the value changes.
  final ValueChanged<double>? onChanged;

  /// Called once when a drag or key press ends.
  final ValueChanged<double>? onChangeEnd;

  /// Accessible name.
  final String semanticLabel;

  /// Smallest value.
  final double min;

  /// Largest value.
  final double max;

  /// Number of equal steps between [min] and [max]; null is continuous.
  final int? divisions;

  /// Text announced for a value; defaults to the number.
  final String Function(double value)? formatValue;

  @override
  State<DlmSlider> createState() => _DlmSliderState();
}

class _DlmSliderState extends State<DlmSlider> {
  bool _hovered = false;
  bool _focused = false;
  bool _focusVisible = false;
  bool _dragging = false;

  bool get _enabled => widget.onChanged != null;

  double _snap(double v) {
    final clamped = v.clamp(widget.min, widget.max);
    final d = widget.divisions;
    if (d == null) return clamped;
    final step = (widget.max - widget.min) / d;
    return widget.min + ((clamped - widget.min) / step).round() * step;
  }

  String _text(double v) =>
      widget.formatValue?.call(v) ??
      double.parse(v.toStringAsFixed(6)).toString();

  double get _step => widget.divisions == null
      ? (widget.max - widget.min) / 10
      : (widget.max - widget.min) / widget.divisions!;

  void _set(double v, {bool end = false}) {
    final next = _snap(v);
    if (next != widget.value) widget.onChanged?.call(next);
    if (end) widget.onChangeEnd?.call(next);
  }

  void _fromDx(double dx, double width, double radius, {bool end = false}) {
    final usable = width - radius * 2;
    final f = usable <= 0 ? 0.0 : ((dx - radius) / usable).clamp(0.0, 1.0);
    _set(widget.min + f * (widget.max - widget.min), end: end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final radius = theme.metrics.icon / 2 + 2;
    final fraction = (widget.value - widget.min) / (widget.max - widget.min);
    return Semantics(
      slider: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      value: _text(widget.value),
      focused: _enabled ? _focused : null,
      increasedValue: _text(_snap(widget.value + _step)),
      decreasedValue: _text(_snap(widget.value - _step)),
      onIncrease: _enabled ? () => _set(widget.value + _step, end: true) : null,
      onDecrease: _enabled ? () => _set(widget.value - _step, end: true) : null,
      child: FocusableActionDetector(
        enabled: _enabled,
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
          SingleActivator(LogicalKeyboardKey.pageUp): _StepIntent(10),
          SingleActivator(LogicalKeyboardKey.pageDown): _StepIntent(-10),
          SingleActivator(LogicalKeyboardKey.home): _JumpIntent(toEnd: false),
          SingleActivator(LogicalKeyboardKey.end): _JumpIntent(toEnd: true),
        },
        actions: {
          _StepIntent: CallbackAction<_StepIntent>(
            onInvoke: (i) {
              _set(widget.value + i.steps * _step, end: true);
              return null;
            },
          ),
          _JumpIntent: CallbackAction<_JumpIntent>(
            onInvoke: (i) {
              _set(i.toEnd ? widget.max : widget.min, end: true);
              return null;
            },
          ),
        },
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focusVisible = v),
        onFocusChange: (v) => setState(() => _focused = v),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : 200.0;
            return ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _enabled
                    ? (d) {
                        setState(() => _dragging = true);
                        _fromDx(d.localPosition.dx, width, radius);
                      }
                    : null,
                onTapUp: _enabled
                    ? (_) {
                        setState(() => _dragging = false);
                        widget.onChangeEnd?.call(widget.value);
                      }
                    : null,
                onTapCancel: _enabled
                    ? () => setState(() => _dragging = false)
                    : null,
                onHorizontalDragStart: _enabled
                    ? (_) => setState(() => _dragging = true)
                    : null,
                onHorizontalDragUpdate: _enabled
                    ? (d) => _fromDx(d.localPosition.dx, width, radius)
                    : null,
                onHorizontalDragEnd: _enabled
                    ? (_) {
                        setState(() => _dragging = false);
                        widget.onChangeEnd?.call(widget.value);
                      }
                    : null,
                child: theme.components.slider(
                  context,
                  fraction: fraction,
                  width: width,
                  thumbRadius: radius,
                  states: DlmStates(
                    hovered: _enabled && _hovered,
                    pressed: _enabled && _dragging,
                    focused: _focused,
                    focusVisible: _focused && _focusVisible,
                    disabled: !_enabled,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
