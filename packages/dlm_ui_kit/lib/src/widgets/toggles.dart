import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../components/components.dart';
import '../theme/theme.dart';

Widget _labelled(
  BuildContext context,
  Widget control,
  String? label,
  bool disabled,
) {
  if (label == null) return control;
  final theme = DlmTheme.of(context);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      control,
      SizedBox(width: theme.metrics.spacing.sm),
      Text(
        label,
        style: theme.typography.body.copyWith(
          color: disabled ? theme.colors.textDisabled : null,
        ),
      ),
    ],
  );
}

/// An on/off switch with an optional visible [label].
class DlmSwitch extends StatelessWidget {
  /// Creates a switch; `onChanged: null` disables it.
  const DlmSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
    this.focusNode,
    super.key,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool>? onChanged;

  /// Visible text beside the switch.
  final String? label;

  /// Accessible name when there is no [label].
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return DlmInteractive(
      role: DlmRole.toggle,
      checked: value,
      semanticLabel: semanticLabel ?? label,
      focusNode: focusNode,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      builder: (context, states) => _labelled(
        context,
        theme.components.switchControl(context, value: value, states: states),
        label,
        states.disabled,
      ),
    );
  }
}

/// A checkbox that can be unchecked, checked or mixed (partly selected).
class DlmCheckbox extends StatelessWidget {
  /// Creates a checkbox; `onChanged: null` disables it.
  const DlmCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
    this.focusNode,
    super.key,
  });

  /// The current state.
  final DlmCheckState value;

  /// Called with the next state. From mixed, activation checks the box.
  final ValueChanged<DlmCheckState>? onChanged;

  /// Visible text beside the box.
  final String? label;

  /// Accessible name when there is no [label].
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return DlmInteractive(
      role: DlmRole.checkbox,
      checked: value == DlmCheckState.checked,
      mixed: value == DlmCheckState.mixed,
      semanticLabel: semanticLabel ?? label,
      focusNode: focusNode,
      onTap: onChanged == null
          ? null
          : () => onChanged!(
              value == DlmCheckState.checked
                  ? DlmCheckState.unchecked
                  : DlmCheckState.checked,
            ),
      builder: (context, states) => _labelled(
        context,
        theme.components.checkbox(context, value: value, states: states),
        label,
        states.disabled,
      ),
    );
  }
}

/// One radio button of a group; the group is the caller's [groupValue].
class DlmRadio<T> extends StatelessWidget {
  /// Creates a radio button; `onChanged: null` disables it.
  const DlmRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.semanticLabel,
    this.focusNode,
    super.key,
  });

  /// The value this button represents.
  final T value;

  /// The currently selected value of the group.
  final T? groupValue;

  /// Called with [value] when the button is chosen.
  final ValueChanged<T>? onChanged;

  /// Visible text beside the button.
  final String? label;

  /// Accessible name when there is no [label].
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final selected = value == groupValue;
    return DlmInteractive(
      role: DlmRole.radio,
      checked: selected,
      semanticLabel: semanticLabel ?? label,
      focusNode: focusNode,
      onTap: onChanged == null || selected ? null : () => onChanged!(value),
      builder: (context, states) => _labelled(
        context,
        theme.components.radio(context, selected: selected, states: states),
        label,
        states.disabled && !selected,
      ),
    );
  }
}
