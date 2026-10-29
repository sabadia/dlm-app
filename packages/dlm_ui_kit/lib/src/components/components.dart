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

/// How a modal surface is presented.
enum DlmDialogKind {
  /// Centred over a dimmed window.
  dialog,

  /// Attached to an edge of the window.
  sheet,
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

  /// Arrow into a tray.
  download,

  /// Arrow out of a tray.
  upload,

  /// Two vertical bars.
  pause,

  /// A right-pointing triangle.
  play,

  /// A square.
  stop,

  /// Counter-clockwise arrow.
  restart,

  /// Clockwise arrow.
  refresh,

  /// A bin.
  trash,

  /// A folder.
  folder,

  /// A page with a folded corner.
  file,

  /// Two chain links.
  link,

  /// Two overlapping sheets.
  copy,

  /// A gear.
  settings,

  /// A list with bullets.
  queue,

  /// A clock.
  schedule,

  /// A label.
  tag,

  /// A funnel.
  filter,

  /// A gauge.
  speed,

  /// Axes with bars.
  chart,

  /// A plug.
  plugin,

  /// A globe.
  globe,

  /// A key.
  key,

  /// Arrow into a bar.
  importIcon,

  /// Arrow out of a bar.
  exportIcon,

  /// A pencil.
  edit,

  /// A padlock.
  lock,

  /// A bell.
  bell,

  /// A window with a left pane.
  sidebar,

  /// A window with a right pane.
  inspector,

  /// Arrow leaving a box.
  externalLink,

  /// Three horizontal lines.
  menu,

  /// Two sliders: how a list looks.
  viewOptions,

  /// Two stacked boxes: grouping.
  group,

  /// A frame split into columns.
  columns,

  /// Two stacked cards.
  cards,
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

  /// The surface of a button around its [content] (label and icon). A
  /// [square] button holds only an icon and has no horizontal padding.
  Widget button(
    BuildContext context, {
    required DlmButtonVariant variant,
    required DlmControlSize size,
    required DlmStates states,
    required Widget content,
    bool square = false,
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

  /// A progress bar drawn at the width it is given. [value] is 0..1, or null
  /// for indeterminate, in which case [phase] (0..1, repeating) places the
  /// moving segment.
  Widget progressBar(
    BuildContext context, {
    required double? value,
    required double phase,
    required DlmTone tone,
  });

  /// A circular progress indicator of edge length [size]; see [progressBar]
  /// for [value] and [phase].
  Widget progressRing(
    BuildContext context, {
    required double? value,
    required double phase,
    required DlmTone tone,
    required double size,
  });

  /// A small status pill around its [content].
  Widget badge(
    BuildContext context, {
    required DlmTone tone,
    required Widget content,
  });

  /// A selectable or removable chip around its [content].
  Widget chip(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  });

  /// One row of a list around its [content]: hover, selection and the
  /// separator.
  Widget listRow(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  });

  /// An inline message box around its [content].
  Widget banner(
    BuildContext context, {
    required DlmTone tone,
    required Widget content,
  });

  /// A transient floating message around its [content].
  Widget toast(
    BuildContext context, {
    required DlmTone tone,
    required Widget content,
  });

  /// The bubble of a tooltip around its [content].
  Widget tooltipBubble(BuildContext context, {required Widget content});

  /// The floating surface of a popover (free-form content).
  Widget popoverSurface(BuildContext context, {required Widget child});

  /// The floating surface of a menu around its items.
  Widget menuSurface(BuildContext context, {required Widget child});

  /// One menu item around its [content]; [checked] draws a check mark slot
  /// when non-null.
  Widget menuItem(
    BuildContext context, {
    required DlmStates states,
    required bool destructive,
    required Widget content,
  });

  /// The closed state of a dropdown around its [content] (value and arrow).
  Widget dropdownTrigger(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  });

  /// The modal surface of a dialog or sheet around its content.
  Widget dialogSurface(
    BuildContext context, {
    required DlmDialogKind kind,
    required Widget child,
  });

  /// The sidebar background around its [child] (sections and items). A
  /// translucent material is drawn as a tinted colour; the native window
  /// provides the blur behind it.
  Widget sidebarSurface(BuildContext context, {required Widget child});

  /// One sidebar item around its [content].
  Widget sidebarItem(
    BuildContext context, {
    required DlmStates states,
    required Widget content,
  });

  /// The toolbar background (title-bar unified, command bar, header bar or
  /// tool bar, per the shell pattern) around its [child].
  Widget toolbar(BuildContext context, {required Widget child});

  /// A titled group of settings rows around its [rows]; [title] and [footer]
  /// are optional captions.
  Widget formGroup(
    BuildContext context, {
    required Widget rows,
    Widget? title,
    Widget? footer,
  });

  /// The draggable divider between two panes; [axis] is the direction the
  /// panes are laid out in.
  Widget splitDivider(
    BuildContext context, {
    required Axis axis,
    required DlmStates states,
  });

  /// The header band of a data table around its column headers.
  Widget tableHeader(BuildContext context, {required Widget child});

  /// One column header around its [content]; [sorted] is the sort direction
  /// when this column is the sort column (true ascending), null otherwise.
  Widget tableHeaderCell(
    BuildContext context, {
    required DlmStates states,
    required bool? sorted,
    required Widget content,
  });

  /// One data row around its cells; [odd] allows striping.
  Widget tableRow(
    BuildContext context, {
    required DlmStates states,
    required bool odd,
    required Widget content,
  });

  /// One cell of the weekday x time grid.
  Widget scheduleCell(
    BuildContext context, {
    required bool on,
    required DlmStates states,
  });
}
