import 'package:flutter/widgets.dart';

import '../behavior/states.dart';

/// The emphasis of a button.
enum DlmButtonVariant {
  /// The main action of a view: accent fill.
  primary,

  /// A normal action.
  secondary,

  /// An action that destroys data.
  destructive,

  /// A low-emphasis action: no fill until hovered.
  plain,
}

/// The size of a control.
enum DlmControlSize {
  /// Dense toolbars and table cells.
  small,

  /// The default.
  regular,

  /// Prominent actions.
  large,
}

/// The state of a checkbox.
enum DlmCheckState {
  /// Not selected.
  unchecked,

  /// Selected.
  checked,

  /// Some of the children are selected.
  mixed,
}

/// The meaning of a badge, banner, toast or progress bar.
enum DlmTone {
  /// No particular meaning.
  neutral,

  /// Brand or selection.
  accent,

  /// Completed or healthy.
  success,

  /// Needs attention.
  warning,

  /// An error.
  danger,

  /// Plain information.
  info,
}

/// The built-in glyphs the kit draws itself. A skin's icon builder may
/// replace any of them (F2.9); features use these names, never raw glyphs.
enum DlmIconName {
  /// Arrow pointing right.
  chevronRight,

  /// Arrow pointing down.
  chevronDown,

  /// Arrow pointing up.
  chevronUp,

  /// Arrow pointing left.
  chevronLeft,

  /// An X.
  close,

  /// A magnifier.
  search,

  /// An open eye.
  eye,

  /// A crossed-out eye.
  eyeOff,

  /// A tick.
  check,

  /// A horizontal bar.
  minus,

  /// A plus sign.
  plus,

  /// An i in a circle.
  info,

  /// An exclamation in a triangle.
  warning,

  /// An exclamation in a circle.
  error,

  /// A tick in a circle.
  success,

  /// Three dots in a row.
  more,

  /// Arrow pointing up for ascending sort.
  sortAscending,

  /// Arrow pointing down for descending sort.
  sortDescending,
}

/// The visual builders a skin supplies for the kit's components.
///
/// The kit's widgets own behaviour (focus, keyboard, hit target, semantics,
/// state) and layout of the content; a skin only draws the surface of each
/// control for a [DlmStates]. [DlmBaseComponents] draws everything from the
/// tokens, so a skin overrides only what it must draw differently.
abstract class DlmComponents {
  /// Creates the component set.
  const DlmComponents();

  /// The surface of a button around its [content] (label and icon).
  Widget button(
    BuildContext context, {
    required DlmButtonVariant variant,
    required DlmControlSize size,
    required DlmStates states,
    required Widget content,
  });

  /// The track and thumb of a switch.
  Widget switchControl(
    BuildContext context, {
    required bool value,
    required DlmStates states,
  });

  /// The box and mark of a checkbox.
  Widget checkbox(
    BuildContext context, {
    required DlmCheckState value,
    required DlmStates states,
  });

  /// The circle and dot of a radio button.
  Widget radio(
    BuildContext context, {
    required bool selected,
    required DlmStates states,
  });

  /// One segment of a segmented control around its [content].
  Widget segment(
    BuildContext context, {
    required bool isFirst,
    required bool isLast,
    required DlmStates states,
    required Widget content,
  });

  /// The frame of a segmented control around its segments.
  Widget segmentedFrame(BuildContext context, {required Widget child});

  /// One tab around its [content].
  Widget tab(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  });

  /// A built-in glyph of [name] at [size] in [color].
  Widget icon(
    BuildContext context,
    DlmIconName name, {
    required double size,
    required Color color,
  });

  /// The frame (fill, border, padding) of a text input around its [child].
  Widget textFieldFrame(
    BuildContext context, {
    required DlmStates states,
    required bool hasError,
    required bool multiline,
    required Widget child,
  });

  /// A slider drawn at [width]: the track filled up to [fraction] (0..1) and
  /// a thumb of radius [thumbRadius]. The kit maps pointer and keys to the
  /// value; the skin only draws.
  Widget slider(
    BuildContext context, {
    required double fraction,
    required double width,
    required double thumbRadius,
    required DlmStates states,
  });
}
