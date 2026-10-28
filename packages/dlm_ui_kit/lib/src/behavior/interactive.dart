import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'double_click.dart';
import 'states.dart';

/// What assistive technology announces a control as.
enum DlmRole {
  /// A push button.
  button,

  /// A link.
  link,

  /// A checkbox (use `checked` for the state).
  checkbox,

  /// A radio button (use `checked` for the state).
  radio,

  /// A switch (use `checked` for the state).
  toggle,

  /// A tab in a tab list (use `selected`).
  tab,

  /// A menu item.
  menuItem,

  /// A row or other selectable item (use `selected`).
  item,
}

/// The behaviour layer of every pressable control: hover, press and focus
/// tracking, keyboard activation (Enter, Space), a minimum hit target and
/// semantics. Skins only draw; they never re-implement this.
class DlmInteractive extends StatefulWidget {
  /// Creates an interactive wrapper that draws with [builder].
  const DlmInteractive({
    required this.builder,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.enabled = true,
    this.selected = false,
    this.checked,
    this.mixed = false,
    this.role = DlmRole.button,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.cursor,
    this.ensureHitTarget = true,
    super.key,
  });

  /// Draws the control for the current [DlmStates].
  final Widget Function(BuildContext context, DlmStates states) builder;

  /// Called on click, tap, Enter or Space. A null callback disables the
  /// control unless [enabled] is explicitly true and another gesture is set.
  final VoidCallback? onTap;

  /// Called on double click.
  final VoidCallback? onDoubleTap;

  /// Called on right click or the context-menu key.
  final VoidCallback? onSecondaryTap;

  /// Whether the control reacts to input.
  final bool enabled;

  /// Whether the control is selected or current.
  final bool selected;

  /// The checked state for checkbox, radio and toggle roles.
  final bool? checked;

  /// The checkbox is in the indeterminate (partly selected) state.
  final bool mixed;

  /// How the control is announced.
  final DlmRole role;

  /// The accessible name; required for controls without visible text.
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  /// Request focus when first built.
  final bool autofocus;

  /// Whether Tab can reach the control.
  final bool canRequestFocus;

  /// Mouse cursor; defaults to the platform arrow, as native desktop buttons.
  final MouseCursor? cursor;

  /// Grow the control to the theme's minimum hit target.
  final bool ensureHitTarget;

  @override
  State<DlmInteractive> createState() => _DlmInteractiveState();
}

class _DlmInteractiveState extends State<DlmInteractive> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;
  bool _focusVisible = false;

  bool get _enabled =>
      widget.enabled &&
      (widget.onTap != null ||
          widget.onDoubleTap != null ||
          widget.onSecondaryTap != null);

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        if (_enabled) widget.onTap?.call();
        return null;
      },
    ),
  };

  static const Map<ShortcutActivator, Intent> _shortcuts = {
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  void _set(VoidCallback change) {
    if (mounted) setState(change);
  }

  @override
  void didUpdateWidget(DlmInteractive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && (_hovered || _pressed)) {
      _hovered = false;
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final states = DlmStates(
      hovered: enabled && _hovered,
      pressed: enabled && _pressed,
      focused: _focused,
      focusVisible: _focused && _focusVisible,
      disabled: !enabled,
      selected: widget.selected,
    );
    final min = DlmTheme.maybeOf(context)?.metrics.minHitTarget ?? 24;

    var child = widget.builder(context, states);
    if (widget.ensureHitTarget) {
      child = ConstrainedBox(
        constraints: BoxConstraints(minWidth: min, minHeight: min),
        child: child,
      );
    }
    child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => _set(() => _pressed = false) : null,
      onTapCancel: enabled ? () => _set(() => _pressed = false) : null,
      onTap: enabled ? widget.onTap : null,
      onSecondaryTap: enabled ? widget.onSecondaryTap : null,
      child: child,
    );
    child = DlmDoubleClick(
      onDoubleClick: enabled ? widget.onDoubleTap : null,
      child: child,
    );
    child = FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      mouseCursor:
          widget.cursor ??
          (enabled ? SystemMouseCursors.basic : MouseCursor.defer),
      shortcuts: _shortcuts,
      actions: _actions,
      onShowHoverHighlight: (v) => _set(() => _hovered = v),
      onShowFocusHighlight: (v) => _set(() => _focusVisible = v),
      onFocusChange: (v) => _set(() => _focused = v),
      child: child,
    );
    return Semantics(
      container: true,
      enabled: enabled,
      focused: enabled && widget.canRequestFocus ? _focused : null,
      button: widget.role == DlmRole.button || widget.role == DlmRole.menuItem,
      link: widget.role == DlmRole.link,
      inMutuallyExclusiveGroup: widget.role == DlmRole.radio ? true : null,
      checked: switch (widget.role) {
        DlmRole.checkbox || DlmRole.radio => widget.checked ?? false,
        _ => null,
      },
      mixed: widget.mixed ? true : null,
      toggled: widget.role == DlmRole.toggle ? (widget.checked ?? false) : null,
      selected: widget.role == DlmRole.tab || widget.role == DlmRole.item
          ? widget.selected
          : null,
      label: widget.semanticLabel,
      onTap: enabled ? widget.onTap : null,
      child: ExcludeSemantics(
        excluding: widget.semanticLabel != null,
        child: child,
      ),
    );
  }
}
