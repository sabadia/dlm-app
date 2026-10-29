import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../behavior/states.dart';
import '../theme/theme.dart';

class _MoveCell extends Intent {
  const _MoveCell(this.dDay, this.dSlot, {this.paint = false});
  final int dDay;
  final int dSlot;
  final bool paint;
}

class _ToggleCell extends Intent {
  const _ToggleCell();
}

class _EdgeCell extends Intent {
  const _EdgeCell({required this.end});
  final bool end;
}

/// An editor for weekly time windows: seven days by [slotsPerDay] slots. A
/// cell is `day * slotsPerDay + slot`; [cells] holds the active ones.
///
/// Drag across cells to paint (the first cell decides whether to set or
/// clear), click a day name to toggle the whole day. With the keyboard the
/// grid is one tab stop: arrows move, Space toggles, Shift+arrows paint, Home
/// and End jump to the ends of the day.
class DlmScheduleGrid extends StatefulWidget {
  /// Creates a schedule grid.
  const DlmScheduleGrid({
    required this.cells,
    required this.onChanged,
    required this.dayLabels,
    required this.slotLabel,
    required this.semanticLabel,
    this.slotsPerDay = 24,
    this.headerEvery = 3,
    super.key,
  }) : assert(dayLabels.length == 7, 'Seven day labels are required.');

  /// The active cells.
  final Set<int> cells;

  /// Called with the new set of active cells.
  final ValueChanged<Set<int>> onChanged;

  /// Seven localised day names in display order (first day of the week
  /// first).
  final List<String> dayLabels;

  /// The localised time text of a slot, e.g. "09:00"; used in headers and in
  /// each cell's accessible name.
  final String Function(int slot) slotLabel;

  /// Accessible name of the grid.
  final String semanticLabel;

  /// Slots per day: 24 for hours, 48 for half hours.
  final int slotsPerDay;

  /// A time header is shown every this many slots.
  final int headerEvery;

  @override
  State<DlmScheduleGrid> createState() => _DlmScheduleGridState();
}

class _DlmScheduleGridState extends State<DlmScheduleGrid> {
  static const double _labelWidth = 96;
  static const double _minCell = 14;

  final FocusNode _focus = FocusNode(debugLabel: 'DlmScheduleGrid');
  int _cursor = 0;
  bool _focused = false;
  bool? _paintValue;
  int? _hover;
  int? _lastDragCell;

  void _endDrag() {
    _paintValue = null;
    _lastDragCell = null;
  }

  int get _days => 7;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted && _focused != _focus.hasFocus) {
        setState(() => _focused = _focus.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// Edits made since the last frame that the parent has not yet fed back.
  /// Several pointer or key events can arrive in one frame; each must build on
  /// the previous one, not on the stale [DlmScheduleGrid.cells].
  Set<int>? _pending;

  bool _has(int cell) => (_pending ?? widget.cells).contains(cell);

  void _setCells(Iterable<int> cells, {required bool on}) {
    final next = {...(_pending ?? widget.cells)};
    var changed = false;
    for (final c in cells) {
      changed |= on ? next.add(c) : next.remove(c);
    }
    if (!changed) return;
    if (_pending == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pending = null);
    }
    _pending = next;
    widget.onChanged(next);
  }

  /// Cells on the straight path from [from] to [to], both included, so a fast
  /// drag leaves no gaps.
  Iterable<int> _path(int from, int to) sync* {
    final slots = widget.slotsPerDay;
    final d0 = from ~/ slots;
    final s0 = from % slots;
    final d1 = to ~/ slots;
    final s1 = to % slots;
    final steps = [
      (d1 - d0).abs(),
      (s1 - s0).abs(),
    ].reduce((a, b) => a > b ? a : b);
    for (var i = 0; i <= steps; i++) {
      final t = steps == 0 ? 0.0 : i / steps;
      final d = (d0 + (d1 - d0) * t).round();
      final s = (s0 + (s1 - s0) * t).round();
      yield d * slots + s;
    }
  }

  int? _cellAt(Offset local, double cellWidth, double cellHeight, double top) {
    final x = local.dx - _labelWidth;
    final y = local.dy - top;
    if (x < 0 || y < 0) return null;
    final slot = x ~/ cellWidth;
    final day = y ~/ cellHeight;
    if (slot >= widget.slotsPerDay || day >= _days) return null;
    return day * widget.slotsPerDay + slot;
  }

  void _toggleDay(int day) {
    final cells = [
      for (var s = 0; s < widget.slotsPerDay; s++) day * widget.slotsPerDay + s,
    ];
    final allOn = cells.every(_has);
    _setCells(cells, on: !allOn);
  }

  void _move(int dDay, int dSlot, {required bool paint}) {
    final day = (_cursor ~/ widget.slotsPerDay + dDay).clamp(0, _days - 1);
    final slot = (_cursor % widget.slotsPerDay + dSlot).clamp(
      0,
      widget.slotsPerDay - 1,
    );
    final next = day * widget.slotsPerDay + slot;
    if (paint) {
      _paintValue ??= !_has(_cursor);
      _setCells([_cursor, next], on: _paintValue!);
    } else {
      _paintValue = null;
    }
    setState(() => _cursor = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final m = theme.metrics;
    final slots = widget.slotsPerDay;
    final cellHeight = m.controlHeightSmall;
    final headerHeight = theme.typography.caption.fontSize! + m.spacing.md;
    return LayoutBuilder(
      builder: (context, box) {
        final available =
            (box.maxWidth.isFinite ? box.maxWidth : 800) - _labelWidth;
        final cellWidth = (available / slots).clamp(_minCell, 64.0);
        final width = _labelWidth + cellWidth * slots;
        final grid = SizedBox(
          width: width,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: widget.semanticLabel,
            child: FocusableActionDetector(
              focusNode: _focus,
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.arrowRight): _MoveCell(0, 1),
                SingleActivator(LogicalKeyboardKey.arrowLeft): _MoveCell(0, -1),
                SingleActivator(LogicalKeyboardKey.arrowDown): _MoveCell(1, 0),
                SingleActivator(LogicalKeyboardKey.arrowUp): _MoveCell(-1, 0),
                SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
                    _MoveCell(0, 1, paint: true),
                SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
                    _MoveCell(0, -1, paint: true),
                SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
                    _MoveCell(1, 0, paint: true),
                SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
                    _MoveCell(-1, 0, paint: true),
                SingleActivator(LogicalKeyboardKey.home): _EdgeCell(end: false),
                SingleActivator(LogicalKeyboardKey.end): _EdgeCell(end: true),
                SingleActivator(LogicalKeyboardKey.space): _ToggleCell(),
              },
              actions: {
                _MoveCell: CallbackAction<_MoveCell>(
                  onInvoke: (i) {
                    _move(i.dDay, i.dSlot, paint: i.paint);
                    return null;
                  },
                ),
                _EdgeCell: CallbackAction<_EdgeCell>(
                  onInvoke: (i) {
                    final day = _cursor ~/ slots;
                    setState(
                      () => _cursor = day * slots + (i.end ? slots - 1 : 0),
                    );
                    _paintValue = null;
                    return null;
                  },
                ),
                _ToggleCell: CallbackAction<_ToggleCell>(
                  onInvoke: (_) {
                    _setCells([_cursor], on: !_has(_cursor));
                    return null;
                  },
                ),
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  _focus.requestFocus();
                  final cell = _cellAt(
                    e.localPosition,
                    cellWidth,
                    cellHeight,
                    headerHeight,
                  );
                  if (cell == null) return;
                  _paintValue = !_has(cell);
                  _lastDragCell = cell;
                  _setCells([cell], on: _paintValue!);
                  setState(() => _cursor = cell);
                },
                onPointerMove: (e) {
                  final paint = _paintValue;
                  if (paint == null) return;
                  final cell = _cellAt(
                    e.localPosition,
                    cellWidth,
                    cellHeight,
                    headerHeight,
                  );
                  if (cell != null) {
                    _setCells(_path(_lastDragCell ?? cell, cell), on: paint);
                    _lastDragCell = cell;
                  }
                },
                onPointerUp: (_) => _endDrag(),
                onPointerCancel: (_) => _endDrag(),
                child: MouseRegion(
                  onHover: (e) {
                    final cell = _cellAt(
                      e.localPosition,
                      cellWidth,
                      cellHeight,
                      headerHeight,
                    );
                    if (cell != _hover) setState(() => _hover = cell);
                  },
                  onExit: (_) => setState(() => _hover = null),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: headerHeight,
                        child: Row(
                          children: [
                            const SizedBox(width: _labelWidth),
                            for (var s = 0; s < slots; s++)
                              SizedBox(
                                width: cellWidth,
                                child: s % widget.headerEvery == 0
                                    ? OverflowBox(
                                        maxWidth:
                                            cellWidth * widget.headerEvery,
                                        alignment: Alignment.centerLeft,
                                        child: ExcludeSemantics(
                                          child: Text(
                                            widget.slotLabel(s),
                                            maxLines: 1,
                                            style: theme.typography.caption
                                                .copyWith(
                                                  color: theme
                                                      .colors
                                                      .textSecondary,
                                                ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                          ],
                        ),
                      ),
                      for (var d = 0; d < _days; d++)
                        SizedBox(
                          height: cellHeight,
                          child: Row(
                            children: [
                              SizedBox(
                                width: _labelWidth,
                                child: DlmInteractive(
                                  semanticLabel: widget.dayLabels[d],
                                  ensureHitTarget: false,
                                  canRequestFocus: false,
                                  onTap: () => _toggleDay(d),
                                  builder: (context, states) => Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      widget.dayLabels[d],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.typography.label.copyWith(
                                        color: states.hovered
                                            ? theme.colors.textLink
                                            : theme.colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              for (var s = 0; s < slots; s++)
                                _cell(
                                  context,
                                  theme,
                                  d * slots + s,
                                  d,
                                  s,
                                  cellWidth,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        return width > box.maxWidth
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: grid,
              )
            : grid;
      },
    );
  }

  Widget _cell(
    BuildContext context,
    DlmThemeData theme,
    int index,
    int day,
    int slot,
    double width,
  ) {
    final on = widget.cells.contains(index);
    final states = DlmStates(
      hovered: _hover == index,
      focused: _focused && _cursor == index,
      focusVisible:
          _focused &&
          _cursor == index &&
          FocusManager.instance.highlightMode == FocusHighlightMode.traditional,
      selected: on,
    );
    return Semantics(
      label: '${widget.dayLabels[day]} ${widget.slotLabel(slot)}',
      checked: on,
      onTap: () => _setCells([index], on: !on),
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: theme.components.scheduleCell(
              context,
              on: on,
              states: states,
            ),
          ),
        ),
      ),
    );
  }
}
