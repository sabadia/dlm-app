import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/double_click.dart';
import '../behavior/interactive.dart';
import '../behavior/states.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'icon.dart';
import 'states.dart';

/// A column of a [DlmDataTable].
class DlmColumn<T> {
  /// Creates a column.
  const DlmColumn({
    required this.id,
    required this.label,
    required this.cell,
    this.width = 140,
    this.minWidth = 48,
    this.maxWidth = 800,
    this.sortable = false,
    this.alignment = AlignmentDirectional.centerStart,
  });

  /// Stable identifier (persisted with column layouts).
  final String id;

  /// Header text.
  final String label;

  /// Builds the cell of [row].
  final Widget Function(BuildContext context, T row) cell;

  /// Initial width when the caller holds no width for this column.
  final double width;

  /// Narrowest the user may make the column.
  final double minWidth;

  /// Widest the user may make the column.
  final double maxWidth;

  /// Whether the header sorts.
  final bool sortable;

  /// Alignment of header and cell content.
  final AlignmentGeometry alignment;
}

/// The current sort of a table.
class DlmSort {
  /// Creates a sort.
  const DlmSort(this.columnId, {required this.ascending});

  /// The sorted column.
  final String columnId;

  /// Direction.
  final bool ascending;
}

/// How rows are selected.
enum DlmSelectionMode {
  /// Rows cannot be selected.
  none,

  /// One row at a time.
  single,

  /// Ctrl/Cmd-click toggles, Shift-click selects a range.
  multiple,
}

/// Localised strings of a data table (the kit holds none).
class DlmTableLabels {
  /// Creates the labels.
  const DlmTableLabels({
    required this.sortedAscending,
    required this.sortedDescending,
    required this.resizeColumn,
    required this.loadingRow,
  });

  /// Announced for the ascending sort column, e.g. "sorted ascending".
  final String sortedAscending;

  /// Announced for the descending sort column.
  final String sortedDescending;

  /// Accessible name of a column's resize handle given the column label.
  final String Function(String column) resizeColumn;

  /// Announced for a row that has not loaded yet.
  final String loadingRow;
}

class _ActivateRow extends Intent {
  const _ActivateRow();
}

class _MoveCursor extends Intent {
  const _MoveCursor(this.delta, {this.extend = false, this.page = false});
  final int delta;
  final bool extend;
  final bool page;
}

class _JumpCursor extends Intent {
  const _JumpCursor({required this.toEnd, this.extend = false});
  final bool toEnd;
  final bool extend;
}

class _ToggleCursor extends Intent {
  const _ToggleCursor();
}

class _SelectAll extends Intent {
  const _SelectAll();
}

/// A virtualized table of [itemCount] rows: sortable, resizable columns, row
/// selection with the usual modifier keys, keyboard navigation and context
/// menus. Rows that have not loaded ([itemAt] returns null) show a skeleton.
///
/// The table is one tab stop. Up/Down (and Page Up/Down, Home/End) move the
/// cursor, Shift extends the selection, Space toggles the cursor row, Ctrl/Cmd+A
/// selects all, Enter activates the cursor row.
class DlmDataTable<T> extends StatefulWidget {
  /// Creates a data table.
  const DlmDataTable({
    required this.columns,
    required this.itemCount,
    required this.itemAt,
    required this.rowId,
    required this.rowSemanticLabel,
    required this.labels,
    required this.semanticLabel,
    this.columnWidths = const {},
    this.onColumnResized,
    this.sort,
    this.onSort,
    this.selectionMode = DlmSelectionMode.multiple,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.onRowActivated,
    this.onRowSecondaryTap,
    this.dragData,
    this.dragFeedback,
    this.isGroupHeader,
    this.groupHeader,
    this.acceptRowDrop,
    this.onRowDrop,
    this.scrollController,
    this.emptyState,
    super.key,
  });

  /// The columns, in display order.
  final List<DlmColumn<T>> columns;

  /// Number of rows, loaded or not.
  final int itemCount;

  /// The row at [index], or null while it loads.
  final T? Function(int index) itemAt;

  /// Stable identity of a row (selection survives sorting and reloads).
  final Object Function(T row) rowId;

  /// Accessible name of a row.
  final String Function(T row) rowSemanticLabel;

  /// Localised strings.
  final DlmTableLabels labels;

  /// Accessible name of the table.
  final String semanticLabel;

  /// Current widths by column id; missing ids use [DlmColumn.width].
  final Map<String, double> columnWidths;

  /// Called while the user resizes a column.
  final void Function(String columnId, double width)? onColumnResized;

  /// The current sort.
  final DlmSort? sort;

  /// Called when the user asks to sort by a column.
  final ValueChanged<DlmSort>? onSort;

  /// How rows are selected.
  final DlmSelectionMode selectionMode;

  /// Ids of the selected rows.
  final Set<Object> selectedIds;

  /// Called with the new selection.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Called on double click or Enter.
  final ValueChanged<T>? onRowActivated;

  /// Called on right click (and the Menu key on the cursor row) with the row
  /// index and the global position for a context menu.
  final void Function(int index, T row, Offset globalPosition)?
  onRowSecondaryTap;

  /// What dragging the row at an index carries to a drop target (for example
  /// the ids of the selection); null makes the row not draggable.
  final Object? Function(int index, T row)? dragData;

  /// The picture that follows the pointer while a row is dragged.
  final Widget Function(BuildContext context, Object data)? dragFeedback;

  /// Whether a row is a group heading: it is drawn by [groupHeader], cannot be
  /// selected and is skipped by the keyboard.
  final bool Function(T row)? isGroupHeader;

  /// Draws the heading row of a group.
  final Widget Function(BuildContext context, T row)? groupHeader;

  /// Whether a dragged [data] may be dropped on the row at [index]; with
  /// [onRowDrop] makes every row a drop target that shows an insertion line.
  final bool Function(int index, T row, Object data)? acceptRowDrop;

  /// Called when [data] is dropped on the row at [index].
  final void Function(int index, T row, Object data)? onRowDrop;

  /// Controls the vertical scroll position.
  final ScrollController? scrollController;

  /// Shown instead of the rows when [itemCount] is zero.
  final Widget? emptyState;

  @override
  State<DlmDataTable<T>> createState() => _DlmDataTableState<T>();
}

class _DlmDataTableState<T> extends State<DlmDataTable<T>> {
  ScrollController? _ownScroll;
  final ScrollController _hScroll = ScrollController();
  final FocusNode _focus = FocusNode(debugLabel: 'DlmDataTable');
  final ValueNotifier<int?> _hover = ValueNotifier<int?>(null);
  final ValueNotifier<int> _cursor = ValueNotifier<int>(0);
  int? _anchor;
  bool _focused = false;

  ScrollController get _scroll =>
      widget.scrollController ?? (_ownScroll ??= ScrollController());

  double _widthOf(DlmColumn<T> c) =>
      (widget.columnWidths[c.id] ?? c.width).clamp(c.minWidth, c.maxWidth);

  double get _totalWidth =>
      widget.columns.fold(0, (sum, c) => sum + _widthOf(c));

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
    _hover.dispose();
    _cursor.dispose();
    _hScroll.dispose();
    _ownScroll?.dispose();
    super.dispose();
  }

  bool get _selectable => widget.selectionMode != DlmSelectionMode.none;

  T? _row(int i) => (i < 0 || i >= widget.itemCount) ? null : widget.itemAt(i);

  bool _isHeader(T? row) =>
      row != null && (widget.isGroupHeader?.call(row) ?? false);

  void _emit(Set<Object> next) => widget.onSelectionChanged?.call(next);

  void _select(int index, {bool toggle = false, bool range = false}) {
    if (!_selectable) return;
    final row = _row(index);
    if (row == null || _isHeader(row)) return;
    final id = widget.rowId(row);
    final multi = widget.selectionMode == DlmSelectionMode.multiple;
    if (range && multi && _anchor != null) {
      final lo = _anchor! < index ? _anchor! : index;
      final hi = _anchor! < index ? index : _anchor!;
      final next = <Object>{if (toggle) ...widget.selectedIds};
      for (var i = lo; i <= hi; i++) {
        final r = _row(i);
        if (r != null && !_isHeader(r)) next.add(widget.rowId(r));
      }
      _emit(next);
    } else if (toggle && multi) {
      final next = {...widget.selectedIds};
      if (!next.remove(id)) next.add(id);
      _emit(next);
      _anchor = index;
    } else {
      _emit({id});
      _anchor = index;
    }
    _cursor.value = index;
  }

  void _moveCursor(int to, {required bool extend}) {
    if (widget.itemCount == 0) return;
    var clamped = to.clamp(0, widget.itemCount - 1);
    // Group headings are passed over, in the direction of the movement.
    final step = clamped >= _cursor.value ? 1 : -1;
    while (_isHeader(_row(clamped))) {
      final next = clamped + step;
      if (next < 0 || next >= widget.itemCount) return;
      clamped = next;
    }
    if (extend && _selectable) {
      _anchor ??= _cursor.value;
      _select(clamped, range: true);
    } else if (_selectable && widget.selectionMode == DlmSelectionMode.single) {
      _select(clamped);
    } else {
      _cursor.value = clamped;
      if (_selectable) {
        // Plain arrow movement selects only the new row (list behaviour).
        _select(clamped);
      }
    }
    _ensureVisible(clamped);
  }

  void _ensureVisible(int index) {
    if (!_scroll.hasClients) return;
    final rowHeight = DlmTheme.of(context).metrics.rowHeight;
    final top = index * rowHeight;
    final bottom = top + rowHeight;
    final pos = _scroll.position;
    if (top < pos.pixels) {
      _scroll.jumpTo(top);
    } else if (bottom > pos.pixels + pos.viewportDimension) {
      _scroll.jumpTo(bottom - pos.viewportDimension);
    }
  }

  int get _pageRows {
    final rowHeight = DlmTheme.of(context).metrics.rowHeight;
    if (!_scroll.hasClients) return 10;
    return (_scroll.position.viewportDimension / rowHeight).floor().clamp(
      1,
      1000,
    );
  }

  void _activate() {
    final row = _row(_cursor.value);
    if (row != null) widget.onRowActivated?.call(row);
  }

  void _selectAll() {
    if (widget.selectionMode != DlmSelectionMode.multiple) return;
    final all = <Object>{};
    for (var i = 0; i < widget.itemCount; i++) {
      final r = _row(i);
      if (r != null && !_isHeader(r)) all.add(widget.rowId(r));
    }
    _emit(all);
  }

  void _sortBy(DlmColumn<T> column) {
    if (!column.sortable || widget.onSort == null) return;
    final current = widget.sort;
    widget.onSort!(
      DlmSort(
        column.id,
        ascending: current?.columnId != column.id || !current!.ascending,
      ),
    );
  }

  void _resize(DlmColumn<T> column, double width) {
    widget.onColumnResized?.call(
      column.id,
      width.clamp(column.minWidth, column.maxWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final rowHeight = theme.metrics.rowHeight;
    final cursorIsRoot = widget.itemCount == 0;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: LayoutBuilder(
        builder: (context, box) {
          final width = _totalWidth < box.maxWidth ? box.maxWidth : _totalWidth;
          return SingleChildScrollView(
            controller: _hScroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: box.maxHeight.isFinite ? box.maxHeight : null,
              child: Column(
                children: [
                  _header(context, theme),
                  Expanded(
                    child: cursorIsRoot
                        ? (widget.emptyState ?? const SizedBox.shrink())
                        : _body(context, theme, rowHeight),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, DlmThemeData theme) {
    return theme.components.tableHeader(
      context,
      child: FocusTraversalGroup(
        child: Row(
          children: [
            for (final c in widget.columns)
              SizedBox(
                width: _widthOf(c),
                child: _HeaderCell<T>(
                  column: c,
                  width: _widthOf(c),
                  sorted: widget.sort?.columnId == c.id
                      ? widget.sort!.ascending
                      : null,
                  labels: widget.labels,
                  onSort: c.sortable && widget.onSort != null
                      ? () => _sortBy(c)
                      : null,
                  onResize: widget.onColumnResized == null
                      ? null
                      : (w) => _resize(c, w),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, DlmThemeData theme, double rowHeight) {
    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowDown): const _MoveCursor(1),
      const SingleActivator(LogicalKeyboardKey.arrowUp): const _MoveCursor(-1),
      const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
          const _MoveCursor(1, extend: true),
      const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
          const _MoveCursor(-1, extend: true),
      const SingleActivator(LogicalKeyboardKey.pageDown): const _MoveCursor(
        1,
        page: true,
      ),
      const SingleActivator(LogicalKeyboardKey.pageUp): const _MoveCursor(
        -1,
        page: true,
      ),
      const SingleActivator(LogicalKeyboardKey.home): const _JumpCursor(
        toEnd: false,
      ),
      const SingleActivator(LogicalKeyboardKey.end): const _JumpCursor(
        toEnd: true,
      ),
      const SingleActivator(LogicalKeyboardKey.home, shift: true):
          const _JumpCursor(toEnd: false, extend: true),
      const SingleActivator(LogicalKeyboardKey.end, shift: true):
          const _JumpCursor(toEnd: true, extend: true),
      const SingleActivator(LogicalKeyboardKey.space): const _ToggleCursor(),
      const SingleActivator(LogicalKeyboardKey.enter): const _ActivateRow(),
      const SingleActivator(LogicalKeyboardKey.keyA, control: true):
          const _SelectAll(),
      const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
          const _SelectAll(),
    };
    return FocusableActionDetector(
      focusNode: _focus,
      shortcuts: shortcuts,
      actions: {
        _MoveCursor: CallbackAction<_MoveCursor>(
          onInvoke: (i) {
            final step = i.page ? _pageRows : 1;
            _moveCursor(_cursor.value + i.delta * step, extend: i.extend);
            return null;
          },
        ),
        _JumpCursor: CallbackAction<_JumpCursor>(
          onInvoke: (i) {
            _moveCursor(i.toEnd ? widget.itemCount - 1 : 0, extend: i.extend);
            return null;
          },
        ),
        _ToggleCursor: CallbackAction<_ToggleCursor>(
          onInvoke: (_) {
            _select(_cursor.value, toggle: true);
            return null;
          },
        ),
        _ActivateRow: CallbackAction<_ActivateRow>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
        _SelectAll: CallbackAction<_SelectAll>(
          onInvoke: (_) {
            _selectAll();
            return null;
          },
        ),
      },
      child: ListView.builder(
        controller: _scroll,
        itemExtent: rowHeight,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) => _buildRow(context, theme, index),
      ),
    );
  }

  Widget _buildRow(BuildContext context, DlmThemeData theme, int index) {
    final row = widget.itemAt(index);
    if (row == null) {
      return _SkeletonRow(columns: widget.columns, widthOf: _widthOf);
    }
    if (_isHeader(row) && widget.groupHeader != null) {
      return Semantics(header: true, child: widget.groupHeader!(context, row));
    }
    final id = widget.rowId(row);
    final selected = widget.selectedIds.contains(id);
    final frame = _RowFrame(
      index: index,
      hover: _hover,
      cursor: _cursor,
      selected: selected,
      tableFocused: _focused,
      label: widget.rowSemanticLabel(row),
      selectable: _selectable,
      onTap: () {
        final k = HardwareKeyboard.instance;
        _focus.requestFocus();
        _select(
          index,
          toggle: k.isControlPressed || k.isMetaPressed,
          range: k.isShiftPressed,
        );
      },
      onDoubleTap: widget.onRowActivated == null
          ? null
          : () => widget.onRowActivated!(row),
      dragData: widget.dragData == null
          ? null
          : () => widget.dragData!(index, row),
      dragFeedback: widget.dragFeedback,
      onSecondaryTap: widget.onRowSecondaryTap == null
          ? null
          : (pos) {
              if (_selectable && !selected) _select(index);
              widget.onRowSecondaryTap!(index, row, pos);
            },
      builder: (context, states) => theme.components.tableRow(
        context,
        states: states,
        odd: index.isOdd,
        content: Row(
          children: [
            for (final c in widget.columns)
              SizedBox(
                width: _widthOf(c),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.metrics.spacing.sm,
                  ),
                  child: Align(
                    alignment: c.alignment,
                    child: c.cell(context, row),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    final onDrop = widget.onRowDrop;
    if (onDrop == null) return frame;
    return _RowDropTarget(
      accepts: (data) => widget.acceptRowDrop?.call(index, row, data) ?? true,
      onDrop: (data) => onDrop(index, row, data),
      child: frame,
    );
  }
}

/// Makes a row accept a drag, drawing an accent line above it meanwhile.
class _RowDropTarget extends StatelessWidget {
  const _RowDropTarget({
    required this.accepts,
    required this.onDrop,
    required this.child,
  });

  final bool Function(Object data) accepts;
  final void Function(Object data) onDrop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = DlmTheme.of(context).colors.accent;
    return DragTarget<Object>(
      onWillAcceptWithDetails: (d) => accepts(d.data),
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, candidates, _) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: candidates.isEmpty
              ? null
              : Border(top: BorderSide(color: accent, width: 2)),
        ),
        child: child,
      ),
    );
  }
}

class _SkeletonRow<T> extends StatelessWidget {
  const _SkeletonRow({required this.columns, required this.widthOf});

  final List<DlmColumn<T>> columns;
  final double Function(DlmColumn<T>) widthOf;

  @override
  Widget build(BuildContext context) {
    final m = DlmTheme.of(context).metrics;
    return Row(
      children: [
        for (final c in columns)
          SizedBox(
            width: widthOf(c),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: m.spacing.sm,
                vertical: m.spacing.md,
              ),
              child: const DlmSkeleton(height: 10),
            ),
          ),
      ],
    );
  }
}

/// One row: tracks hover and cursor through notifiers so a hover change
/// rebuilds two rows, not the list.
class _RowFrame extends StatefulWidget {
  const _RowFrame({
    required this.index,
    required this.hover,
    required this.cursor,
    required this.selected,
    required this.tableFocused,
    required this.label,
    required this.selectable,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSecondaryTap,
    required this.builder,
    this.dragData,
    this.dragFeedback,
  });

  final int index;
  final ValueNotifier<int?> hover;
  final ValueNotifier<int> cursor;
  final bool selected;
  final bool tableFocused;
  final String label;
  final bool selectable;
  final VoidCallback onTap;
  final Object? Function()? dragData;
  final Widget Function(BuildContext context, Object data)? dragFeedback;
  final VoidCallback? onDoubleTap;
  final void Function(Offset globalPosition)? onSecondaryTap;
  final Widget Function(BuildContext, DlmStates) builder;

  @override
  State<_RowFrame> createState() => _RowFrameState();
}

class _RowFrameState extends State<_RowFrame> {
  late bool _hovered = widget.hover.value == widget.index;
  late bool _isCursor = widget.cursor.value == widget.index;

  @override
  void initState() {
    super.initState();
    widget.hover.addListener(_sync);
    widget.cursor.addListener(_sync);
  }

  @override
  void didUpdateWidget(_RowFrame old) {
    super.didUpdateWidget(old);
    if (old.hover != widget.hover) {
      old.hover.removeListener(_sync);
      widget.hover.addListener(_sync);
    }
    if (old.cursor != widget.cursor) {
      old.cursor.removeListener(_sync);
      widget.cursor.addListener(_sync);
    }
    _sync();
  }

  void _sync() {
    final h = widget.hover.value == widget.index;
    final c = widget.cursor.value == widget.index;
    if (h != _hovered || c != _isCursor) {
      setState(() {
        _hovered = h;
        _isCursor = c;
      });
    }
  }

  @override
  void dispose() {
    widget.hover.removeListener(_sync);
    widget.cursor.removeListener(_sync);
    super.dispose();
  }

  /// Makes the row draggable sideways, so vertical scrolling is untouched.
  Widget _draggable(Widget child) {
    final data = widget.dragData?.call();
    if (data == null) return child;
    return _RowDrag(data: data, feedback: widget.dragFeedback, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final focusVisible =
        widget.tableFocused &&
        _isCursor &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final states = DlmStates(
      hovered: _hovered,
      focused: widget.tableFocused,
      focusVisible: focusVisible,
      selected: widget.selected,
    );
    return Semantics(
      container: true,
      label: widget.label,
      selected: widget.selectable ? widget.selected : null,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: MouseRegion(
          onEnter: (_) => widget.hover.value = widget.index,
          onExit: (_) {
            if (widget.hover.value == widget.index) widget.hover.value = null;
          },
          child: DlmDoubleClick(
            onDoubleClick: widget.onDoubleTap,
            child: _draggable(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                onSecondaryTapUp: widget.onSecondaryTap == null
                    ? null
                    : (d) => widget.onSecondaryTap!(d.globalPosition),
                child: widget.builder(context, states),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCell<T> extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.width,
    required this.sorted,
    required this.labels,
    required this.onSort,
    required this.onResize,
  });

  final DlmColumn<T> column;
  final double width;
  final bool? sorted;
  final DlmTableLabels labels;
  final VoidCallback? onSort;
  final ValueChanged<double>? onResize;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final suffix = sorted == null
        ? ''
        : ', ${sorted! ? labels.sortedAscending : labels.sortedDescending}';
    final cell = DlmInteractive(
      semanticLabel: '${column.label}$suffix',
      ensureHitTarget: false,
      canRequestFocus: onSort != null,
      onTap: onSort,
      builder: (context, states) => theme.components.tableHeaderCell(
        context,
        states: onSort == null ? states.copyWith(hovered: false) : states,
        sorted: sorted,
        content: Align(
          alignment: column.alignment,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  column.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (sorted != null) ...[
                SizedBox(width: theme.metrics.spacing.xs),
                DlmIcon(
                  sorted!
                      ? DlmIconName.sortAscending
                      : DlmIconName.sortDescending,
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (onResize == null) return cell;
    return Stack(
      children: [
        Positioned.fill(
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(
                LogicalKeyboardKey.arrowRight,
                control: true,
              ): () =>
                  onResize!(width + 8),
              const SingleActivator(
                LogicalKeyboardKey.arrowLeft,
                control: true,
              ): () =>
                  onResize!(width - 8),
            },
            child: cell,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 8,
          child: Semantics(
            label: labels.resizeColumn(column.label),
            value: '${width.round()}',
            increasedValue: '${(width + 8).round()}',
            decreasedValue: '${(width - 8).round()}',
            onIncrease: () => onResize!(width + 8),
            onDecrease: () => onResize!(width - 8),
            child: ExcludeSemantics(
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) => onResize!(width + d.delta.dx),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Drags [data] to a drop target when the pointer moves sideways (vertical
/// movement is left to scrolling).
class _RowDrag extends StatelessWidget {
  const _RowDrag({required this.data, required this.child, this.feedback});

  final Object data;
  final Widget Function(BuildContext context, Object data)? feedback;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final picture = feedback;
    return Draggable<Object>(
      affinity: Axis.horizontal,
      maxSimultaneousDrags: 1,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      data: data,
      feedback: picture == null
          ? const SizedBox.shrink()
          : IgnorePointer(child: picture(context, data)),
      child: child,
    );
  }
}
