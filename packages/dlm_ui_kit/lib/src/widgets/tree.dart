import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/double_click.dart';
import '../behavior/states.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'icon.dart';

/// A node of a [DlmTree]. A node without children is a leaf (a file).
class DlmTreeNode {
  /// Creates a node.
  const DlmTreeNode({
    required this.id,
    required this.label,
    this.children = const [],
    this.icon,
    this.trailing,
  });

  /// Stable identity (a path).
  final Object id;

  /// The visible text.
  final String label;

  /// Child nodes; empty for a leaf.
  final List<DlmTreeNode> children;

  /// An icon before the label.
  final Widget? icon;

  /// A widget at the trailing edge (a size).
  final Widget? trailing;

  /// Whether the node has no children.
  bool get isLeaf => children.isEmpty;
}

class _Entry {
  const _Entry(this.node, this.level, this.parent);
  final DlmTreeNode node;
  final int level;
  final int? parent;
}

class _Move extends Intent {
  const _Move(this.delta);
  final int delta;
}

class _Jump extends Intent {
  const _Jump({required this.toEnd});
  final bool toEnd;
}

class _Fold extends Intent {
  const _Fold({required this.expand});
  final bool expand;
}

class _Check extends Intent {
  const _Check();
}

class _Activate extends Intent {
  const _Activate();
}

/// A virtualized tree with expandable folders and tri-state checkboxes, for
/// choosing files. [checkedIds] holds the *leaf* ids that are checked; a
/// folder shows checked, unchecked or mixed from its leaves and toggling it
/// checks or unchecks all of them.
///
/// The tree is one tab stop: Up/Down move, Right expands (or enters the
/// first child), Left collapses (or goes to the parent), Space toggles the
/// check, Enter activates, Home/End jump.
class DlmTree extends StatefulWidget {
  /// Creates a tree; leave [onCheckedChanged] null for a tree without
  /// checkboxes.
  const DlmTree({
    required this.roots,
    required this.expandedIds,
    required this.onExpandedChanged,
    required this.semanticLabel,
    this.checkedIds = const {},
    this.onCheckedChanged,
    this.onActivated,
    this.scrollController,
    super.key,
  });

  /// The top-level nodes.
  final List<DlmTreeNode> roots;

  /// Ids of the expanded folders.
  final Set<Object> expandedIds;

  /// Called with the new set of expanded folders.
  final ValueChanged<Set<Object>> onExpandedChanged;

  /// Accessible name of the tree.
  final String semanticLabel;

  /// Ids of the checked leaves.
  final Set<Object> checkedIds;

  /// Called with the new set of checked leaves; null hides the checkboxes.
  final ValueChanged<Set<Object>>? onCheckedChanged;

  /// Called on double click or Enter.
  final ValueChanged<DlmTreeNode>? onActivated;

  /// Controls the scroll position.
  final ScrollController? scrollController;

  @override
  State<DlmTree> createState() => _DlmTreeState();
}

class _DlmTreeState extends State<DlmTree> {
  final FocusNode _focus = FocusNode(debugLabel: 'DlmTree');
  final ValueNotifier<int> _cursor = ValueNotifier<int>(0);
  final ValueNotifier<int?> _hover = ValueNotifier<int?>(null);
  ScrollController? _ownScroll;
  bool _focused = false;

  List<_Entry> _visible = const [];
  Map<Object, (int, int)> _counts = const {};
  Object? _countsRoots;
  Object? _countsChecked;

  ScrollController get _scroll =>
      widget.scrollController ?? (_ownScroll ??= ScrollController());

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
    _cursor.dispose();
    _hover.dispose();
    _ownScroll?.dispose();
    super.dispose();
  }

  void _rebuildModel() {
    final visible = <_Entry>[];
    void walk(List<DlmTreeNode> nodes, int level, int? parent) {
      for (final n in nodes) {
        final index = visible.length;
        visible.add(_Entry(n, level, parent));
        if (!n.isLeaf && widget.expandedIds.contains(n.id)) {
          walk(n.children, level + 1, index);
        }
      }
    }

    walk(widget.roots, 0, null);
    _visible = visible;
    if (widget.onCheckedChanged != null &&
        (!identical(_countsRoots, widget.roots) ||
            !identical(_countsChecked, widget.checkedIds))) {
      final counts = <Object, (int, int)>{};
      (int, int) count(DlmTreeNode n) {
        if (n.isLeaf) {
          final c = (1, widget.checkedIds.contains(n.id) ? 1 : 0);
          counts[n.id] = c;
          return c;
        }
        var total = 0;
        var checked = 0;
        for (final child in n.children) {
          final (t, c) = count(child);
          total += t;
          checked += c;
        }
        counts[n.id] = (total, checked);
        return (total, checked);
      }

      for (final r in widget.roots) {
        count(r);
      }
      _counts = counts;
      _countsRoots = widget.roots;
      _countsChecked = widget.checkedIds;
    }
    if (_cursor.value >= visible.length) {
      _cursor.value = visible.isEmpty ? 0 : visible.length - 1;
    }
  }

  DlmCheckState _stateOf(DlmTreeNode n) {
    final (total, checked) = _counts[n.id] ?? (0, 0);
    if (total == 0 || checked == 0) return DlmCheckState.unchecked;
    return checked == total ? DlmCheckState.checked : DlmCheckState.mixed;
  }

  void _toggleCheck(DlmTreeNode node) {
    final handler = widget.onCheckedChanged;
    if (handler == null) return;
    final leaves = <Object>[];
    void collect(DlmTreeNode n) {
      if (n.isLeaf) {
        leaves.add(n.id);
      } else {
        n.children.forEach(collect);
      }
    }

    collect(node);
    final next = {...widget.checkedIds};
    final allChecked = leaves.isNotEmpty && leaves.every(next.contains);
    if (allChecked) {
      next.removeAll(leaves);
    } else {
      next.addAll(leaves);
    }
    handler(next);
  }

  void _setExpanded(DlmTreeNode node, {required bool expanded}) {
    final next = {...widget.expandedIds};
    if (expanded) {
      next.add(node.id);
    } else {
      next.remove(node.id);
    }
    widget.onExpandedChanged(next);
  }

  void _moveTo(int index) {
    if (_visible.isEmpty) return;
    final i = index.clamp(0, _visible.length - 1);
    _cursor.value = i;
    if (!_scroll.hasClients) return;
    final rowHeight = DlmTheme.of(context).metrics.rowHeight;
    final top = i * rowHeight;
    final pos = _scroll.position;
    if (top < pos.pixels) {
      _scroll.jumpTo(top);
    } else if (top + rowHeight > pos.pixels + pos.viewportDimension) {
      _scroll.jumpTo(top + rowHeight - pos.viewportDimension);
    }
  }

  void _fold({required bool expand}) {
    if (_visible.isEmpty) return;
    final entry = _visible[_cursor.value];
    final node = entry.node;
    final isOpen = widget.expandedIds.contains(node.id);
    if (expand) {
      if (node.isLeaf) return;
      if (!isOpen) {
        _setExpanded(node, expanded: true);
      } else {
        _moveTo(_cursor.value + 1);
      }
    } else {
      if (!node.isLeaf && isOpen) {
        _setExpanded(node, expanded: false);
      } else if (entry.parent != null) {
        _moveTo(entry.parent!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _rebuildModel();
    final theme = DlmTheme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        focusNode: _focus,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowDown): _Move(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _Move(-1),
          SingleActivator(LogicalKeyboardKey.arrowRight): _Fold(expand: true),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _Fold(expand: false),
          SingleActivator(LogicalKeyboardKey.home): _Jump(toEnd: false),
          SingleActivator(LogicalKeyboardKey.end): _Jump(toEnd: true),
          SingleActivator(LogicalKeyboardKey.space): _Check(),
          SingleActivator(LogicalKeyboardKey.enter): _Activate(),
        },
        actions: {
          _Move: CallbackAction<_Move>(
            onInvoke: (i) {
              _moveTo(_cursor.value + i.delta);
              return null;
            },
          ),
          _Jump: CallbackAction<_Jump>(
            onInvoke: (i) {
              _moveTo(i.toEnd ? _visible.length - 1 : 0);
              return null;
            },
          ),
          _Fold: CallbackAction<_Fold>(
            onInvoke: (i) {
              _fold(expand: i.expand);
              return null;
            },
          ),
          _Check: CallbackAction<_Check>(
            onInvoke: (_) {
              if (_visible.isNotEmpty) {
                _toggleCheck(_visible[_cursor.value].node);
              }
              return null;
            },
          ),
          _Activate: CallbackAction<_Activate>(
            onInvoke: (_) {
              if (_visible.isNotEmpty) {
                widget.onActivated?.call(_visible[_cursor.value].node);
              }
              return null;
            },
          ),
        },
        child: ListView.builder(
          controller: _scroll,
          itemExtent: theme.metrics.rowHeight,
          itemCount: _visible.length,
          itemBuilder: (context, i) => _TreeRow(
            key: ValueKey(_visible[i].node.id),
            index: i,
            entry: _visible[i],
            hover: _hover,
            cursor: _cursor,
            tableFocused: _focused,
            expanded: widget.expandedIds.contains(_visible[i].node.id),
            checkState: widget.onCheckedChanged == null
                ? null
                : _stateOf(_visible[i].node),
            onSelect: () {
              _focus.requestFocus();
              _moveTo(i);
            },
            onToggleExpanded: () => _setExpanded(
              _visible[i].node,
              expanded: !widget.expandedIds.contains(_visible[i].node.id),
            ),
            onToggleCheck: () => _toggleCheck(_visible[i].node),
            onActivate: widget.onActivated == null
                ? null
                : () => widget.onActivated!(_visible[i].node),
          ),
        ),
      ),
    );
  }
}

class _TreeRow extends StatefulWidget {
  const _TreeRow({
    required this.index,
    required this.entry,
    required this.hover,
    required this.cursor,
    required this.tableFocused,
    required this.expanded,
    required this.checkState,
    required this.onSelect,
    required this.onToggleExpanded,
    required this.onToggleCheck,
    required this.onActivate,
    super.key,
  });

  final int index;
  final _Entry entry;
  final ValueNotifier<int?> hover;
  final ValueNotifier<int> cursor;
  final bool tableFocused;
  final bool expanded;
  final DlmCheckState? checkState;
  final VoidCallback onSelect;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleCheck;
  final VoidCallback? onActivate;

  @override
  State<_TreeRow> createState() => _TreeRowState();
}

class _TreeRowState extends State<_TreeRow> {
  late bool _hovered = widget.hover.value == widget.index;
  late bool _isCursor = widget.cursor.value == widget.index;

  @override
  void initState() {
    super.initState();
    widget.hover.addListener(_sync);
    widget.cursor.addListener(_sync);
  }

  @override
  void didUpdateWidget(_TreeRow old) {
    super.didUpdateWidget(old);
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

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final m = theme.metrics;
    final node = widget.entry.node;
    final states = DlmStates(
      hovered: _hovered,
      focused: widget.tableFocused,
      focusVisible:
          widget.tableFocused &&
          _isCursor &&
          FocusManager.instance.highlightMode == FocusHighlightMode.traditional,
      selected: _isCursor,
    );
    final indent = widget.entry.level * (m.icon + m.spacing.sm);
    final gap = SizedBox(width: m.spacing.sm);
    final isFolder = !node.isLeaf;
    return Semantics(
      container: true,
      label: node.label,
      selected: _isCursor,
      expanded: isFolder ? widget.expanded : null,
      checked: widget.checkState == null
          ? null
          : widget.checkState == DlmCheckState.checked,
      mixed: widget.checkState == DlmCheckState.mixed ? true : null,
      onTap: widget.onSelect,
      child: ExcludeSemantics(
        child: MouseRegion(
          onEnter: (_) => widget.hover.value = widget.index,
          onExit: (_) {
            if (widget.hover.value == widget.index) widget.hover.value = null;
          },
          child: DlmDoubleClick(
            onDoubleClick:
                widget.onActivate ??
                (isFolder ? widget.onToggleExpanded : null),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onSelect,
              child: theme.components.tableRow(
                context,
                states: states,
                odd: false,
                content: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: indent + m.spacing.sm,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: m.icon,
                        child: isFolder
                            ? GestureDetector(
                                key: ValueKey('dlm-tree-toggle-${node.id}'),
                                behavior: HitTestBehavior.opaque,
                                onTap: widget.onToggleExpanded,
                                child: DlmIcon(
                                  widget.expanded
                                      ? DlmIconName.chevronDown
                                      : DlmIconName.chevronRight,
                                ),
                              )
                            : null,
                      ),
                      gap,
                      if (widget.checkState != null) ...[
                        GestureDetector(
                          key: ValueKey('dlm-tree-check-${node.id}'),
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onToggleCheck,
                          child: theme.components.checkbox(
                            context,
                            value: widget.checkState!,
                            states: DlmStates.idle,
                          ),
                        ),
                        gap,
                      ],
                      if (node.icon != null) ...[node.icon!, gap],
                      Expanded(
                        child: Text(
                          node.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (node.trailing != null) ...[
                        gap,
                        node.trailing!,
                        SizedBox(width: m.spacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
