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
}
