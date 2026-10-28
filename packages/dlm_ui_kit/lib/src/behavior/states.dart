import '../theme/token_value.dart';

/// The interaction state of a control, passed to skin builders so they can
/// draw hover, pressed, focus and disabled looks.
class DlmStates extends DlmTokenValue {
  /// Creates a state; everything defaults to the idle, enabled look.
  const DlmStates({
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
    this.focusVisible = false,
    this.disabled = false,
    this.selected = false,
  });

  /// The idle, enabled state.
  static const DlmStates idle = DlmStates();

  /// The pointer is over the control.
  final bool hovered;

  /// A pointer button or activation key is down on the control.
  final bool pressed;

  /// The control has keyboard focus.
  final bool focused;

  /// Focus should be drawn: keyboard navigation, not a mouse click.
  final bool focusVisible;

  /// The control does not react to input.
  final bool disabled;

  /// The control is selected, checked or current.
  final bool selected;

  /// A copy with the given fields replaced.
  DlmStates copyWith({
    bool? hovered,
    bool? pressed,
    bool? focused,
    bool? focusVisible,
    bool? disabled,
    bool? selected,
  }) => DlmStates(
    hovered: hovered ?? this.hovered,
    pressed: pressed ?? this.pressed,
    focused: focused ?? this.focused,
    focusVisible: focusVisible ?? this.focusVisible,
    disabled: disabled ?? this.disabled,
    selected: selected ?? this.selected,
  );

  @override
  List<Object?> get props => [
    hovered,
    pressed,
    focused,
    focusVisible,
    disabled,
    selected,
  ];
}
