import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'icon.dart';
import 'menu.dart';
import 'popover.dart';
import 'text_field.dart';

/// One choice of a [DlmDropdown] or [DlmComboBox].
class DlmChoice<T> {
  /// Creates a choice.
  const DlmChoice({required this.value, required this.label, this.icon});

  /// The value reported when chosen.
  final T value;

  /// The visible text.
  final String label;

  /// An icon before the text.
  final Widget? icon;
}

/// A closed control showing the selected [DlmChoice]; opens a menu of all
/// choices. Enter, Space and Arrow Down open it; typing jumps to a choice.
class DlmDropdown<T> extends StatefulWidget {
  /// Creates a dropdown; `onChanged: null` disables it.
  const DlmDropdown({
    required this.choices,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.placeholder,
    super.key,
  });

  /// The choices.
  final List<DlmChoice<T>> choices;

  /// The selected value; null shows the [placeholder].
  final T? value;

  /// Called with the chosen value.
  final ValueChanged<T>? onChanged;

  /// Accessible name (what is being chosen).
  final String semanticLabel;

  /// Text shown while nothing is selected.
  final String? placeholder;

  @override
  State<DlmDropdown<T>> createState() => _DlmDropdownState<T>();
}

class _DlmDropdownState<T> extends State<DlmDropdown<T>> {
  final DlmPopoverController _controller = DlmPopoverController();

  DlmChoice<T>? get _selected {
    for (final c in widget.choices) {
      if (c.value == widget.value) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final selected = _selected;
    final enabled = widget.onChanged != null;
    return DlmPopover(
      controller: _controller,
      matchAnchorWidth: true,
      surface: false,
      popoverBuilder: (_) => DlmMenuPanel(
        onClose: _controller.hide,
        entries: [
          for (final c in widget.choices)
            DlmMenuItem(
              label: c.label,
              icon: c.icon,
              checked: c.value == widget.value,
              onPressed: () => widget.onChanged?.call(c.value),
            ),
        ],
      ),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            if (enabled) _controller.show();
          },
        },
        child: DlmInteractive(
          semanticLabel:
              '${widget.semanticLabel}, ${selected?.label ?? widget.placeholder ?? ''}',
          ensureHitTarget: false,
          onTap: enabled ? _controller.toggle : null,
          builder: (context, states) => theme.components.dropdownTrigger(
            context,
            states: states,
            content: Row(
              children: [
                if (selected?.icon != null) ...[
                  selected!.icon!,
                  SizedBox(width: theme.metrics.spacing.sm),
                ],
                Expanded(
                  child: Text(
                    selected?.label ?? widget.placeholder ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.copyWith(
                      color: selected == null
                          ? theme.colors.textDisabled
                          : (states.disabled
                                ? theme.colors.textDisabled
                                : theme.colors.textPrimary),
                    ),
                  ),
                ),
                SizedBox(width: theme.metrics.spacing.sm),
                const DlmIcon(DlmIconName.chevronDown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A text input with a list of suggestions that narrows as the user types.
/// The user may type a value that is not in the list ([onChanged]) or pick
/// one ([onSelected]). Arrow keys move the highlight, Enter picks it, Escape
/// closes the list; focus stays in the text field.
class DlmComboBox<T> extends StatefulWidget {
  /// Creates a combo box.
  const DlmComboBox({
    required this.choices,
    required this.onSelected,
    required this.semanticLabel,
    this.controller,
    this.onChanged,
    this.placeholder,
    this.errorText,
    super.key,
  });

  /// The suggestions.
  final List<DlmChoice<T>> choices;

  /// Called with the value of the picked suggestion.
  final ValueChanged<T> onSelected;

  /// Accessible name.
  final String semanticLabel;

  /// Holds the text; an internal one is used when null.
  final TextEditingController? controller;

  /// Called on every edit of the text.
  final ValueChanged<String>? onChanged;

  /// Hint shown while empty.
  final String? placeholder;

  /// Shown below the field and marks it invalid.
  final String? errorText;

  @override
  State<DlmComboBox<T>> createState() => _DlmComboBoxState<T>();
}

class _DlmComboBoxState<T> extends State<DlmComboBox<T>> {
  final DlmPopoverController _popover = DlmPopoverController();
  final FocusNode _focus = FocusNode();
  TextEditingController? _own;
  int _highlight = 0;

  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  List<DlmChoice<T>> get _matches {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return widget.choices;
    return [
      for (final c in widget.choices)
        if (c.label.toLowerCase().contains(q)) c,
    ];
  }

  void _pick(DlmChoice<T> c) {
    _controller.text = c.label;
    _controller.selection = TextSelection.collapsed(offset: c.label.length);
    _popover.hide();
    widget.onSelected(c.value);
  }

  void _move(int delta) {
    final n = _matches.length;
    if (n == 0) return;
    if (!_popover.isShowing) {
      setState(() => _highlight = 0);
      _popover.show();
      return;
    }
    setState(() => _highlight = (_highlight + delta) % n);
  }

  @override
  void dispose() {
    _focus.dispose();
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final matches = _matches;
        final highlight = matches.isEmpty
            ? null
            : _highlight.clamp(0, matches.length - 1);
        return DlmPopover(
          controller: _popover,
          matchAnchorWidth: true,
          surface: false,
          popoverBuilder: (_) => matches.isEmpty
              ? const SizedBox.shrink()
              : DlmMenuPanel(
                  autofocus: false,
                  highlightedIndex: highlight,
                  onClose: _popover.hide,
                  entries: [
                    for (final c in matches)
                      DlmMenuItem(
                        label: c.label,
                        icon: c.icon,
                        onPressed: () => _pick(c),
                      ),
                  ],
                ),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _move(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _move(-1),
              const SingleActivator(LogicalKeyboardKey.enter): () {
                if (_popover.isShowing && highlight != null) {
                  _pick(matches[highlight]);
                }
              },
              const SingleActivator(LogicalKeyboardKey.escape): _popover.hide,
            },
            child: DlmTextField(
              controller: _controller,
              focusNode: _focus,
              placeholder: widget.placeholder,
              semanticLabel: widget.semanticLabel,
              errorText: widget.errorText,
              onChanged: (text) {
                widget.onChanged?.call(text);
                setState(() => _highlight = 0);
                if (!_popover.isShowing && _matches.isNotEmpty) {
                  _popover.show();
                  // Typing keeps focus: the popover never takes it.
                  _focus.requestFocus();
                }
              },
              suffix: const DlmIcon(DlmIconName.chevronDown),
            ),
          ),
        );
      },
    );
  }
}
