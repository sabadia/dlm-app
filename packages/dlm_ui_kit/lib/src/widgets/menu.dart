import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'button.dart';
import 'icon.dart';
import 'popover.dart';

/// One entry of a menu.
sealed class DlmMenuEntry {
  const DlmMenuEntry();
}

/// A menu command.
class DlmMenuItem extends DlmMenuEntry {
  /// Creates a menu item; `onPressed: null` disables it.
  const DlmMenuItem({
    required this.label,
    required this.onPressed,
    this.icon,
    this.shortcut,
    this.destructive = false,
    this.checked,
  });

  /// The text.
  final String label;

  /// Called when the item is chosen (after the menu has closed).
  final VoidCallback? onPressed;

  /// An icon before the text.
  final Widget? icon;

  /// The keyboard shortcut as text, shown at the trailing edge (formatted
  /// for the platform by the caller).
  final String? shortcut;

  /// Whether the command destroys data; drawn with the danger colour.
  final bool destructive;

  /// A check mark column: true shows a check, false an empty slot, null no
  /// column at all.
  final bool? checked;
}

/// A line between groups of items.
class DlmMenuSeparator extends DlmMenuEntry {
  /// Creates a separator.
  const DlmMenuSeparator();
}

/// A non-interactive group heading.
class DlmMenuHeader extends DlmMenuEntry {
  /// Creates a header.
  const DlmMenuHeader(this.label);

  /// The heading text.
  final String label;
}

/// The items of a menu in the skin's menu surface, with keyboard navigation:
/// Up/Down move, Enter activates, typing a letter jumps to the next item that
/// starts with it. [onSelected] runs after [onClose].
class DlmMenuPanel extends StatefulWidget {
  /// Creates a menu panel.
  const DlmMenuPanel({
    required this.entries,
    required this.onClose,
    this.highlightedIndex,
    this.autofocus = true,
    super.key,
  });

  /// The entries.
  final List<DlmMenuEntry> entries;

  /// Closes the menu; called before an item's callback.
  final VoidCallback onClose;

  /// Index into [entries] drawn as active without holding focus (the
  /// combobox pattern); null uses real focus.
  final int? highlightedIndex;

  /// Focus the first enabled item when shown.
  final bool autofocus;

  @override
  State<DlmMenuPanel> createState() => _DlmMenuPanelState();
}

class _DlmMenuPanelState extends State<DlmMenuPanel> {
  final Map<int, FocusNode> _nodes = {};
  String _typed = '';
  DateTime _typedAt = DateTime.fromMillisecondsSinceEpoch(0);

  FocusNode _node(int i) =>
      _nodes.putIfAbsent(i, () => FocusNode(debugLabel: 'menu item $i'));

  bool _enabled(DlmMenuEntry e) => e is DlmMenuItem && e.onPressed != null;

  @override
  void didUpdateWidget(DlmMenuPanel old) {
    super.didUpdateWidget(old);
    final stale = _nodes.keys.where((i) => i >= widget.entries.length).toList();
    for (final i in stale) {
      _nodes.remove(i)?.dispose();
    }
  }

  @override
  void dispose() {
    for (final n in _nodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  void _choose(DlmMenuItem item) {
    widget.onClose();
    item.onPressed?.call();
  }

  KeyEventResult _typeahead(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final ch = event.character;
    if (ch == null || ch.trim().isEmpty) return KeyEventResult.ignored;
    final now = DateTime.now();
    _typed = now.difference(_typedAt) > const Duration(seconds: 1)
        ? ch.toLowerCase()
        : _typed + ch.toLowerCase();
    _typedAt = now;
    final entries = widget.entries;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      if (_enabled(e) &&
          (e as DlmMenuItem).label.toLowerCase().startsWith(_typed)) {
        _node(i).requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final m = theme.metrics;
    final anyChecked = widget.entries.any(
      (e) => e is DlmMenuItem && e.checked != null,
    );
    final firstEnabled = widget.entries.indexWhere(_enabled);
    final children = <Widget>[];
    for (var i = 0; i < widget.entries.length; i++) {
      final e = widget.entries[i];
      switch (e) {
        case DlmMenuSeparator():
          children.add(
            Padding(
              padding: EdgeInsets.symmetric(vertical: m.spacing.xs),
              child: SizedBox(
                height: m.borderWidth,
                child: ColoredBox(color: theme.colors.separator),
              ),
            ),
          );
        case DlmMenuHeader(:final label):
          children.add(
            Semantics(
              header: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  m.spacing.sm,
                  m.spacing.sm,
                  m.spacing.sm,
                  m.spacing.xs,
                ),
                child: Text(
                  label,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        case DlmMenuItem():
          children.add(
            _buildItem(context, theme, e, i, i == firstEnabled, anyChecked),
          );
      }
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: theme.components.menuSurface(
        context,
        child: IntrinsicWidth(
          child: Focus(
            canRequestFocus: false,
            onKeyEvent: _typeahead,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                    FocusManager.instance.primaryFocus?.nextFocus(),
                const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                    FocusManager.instance.primaryFocus?.previousFocus(),
              },
              child: FocusTraversalGroup(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    DlmThemeData theme,
    DlmMenuItem item,
    int index,
    bool isFirstEnabled,
    bool anyChecked,
  ) {
    final m = theme.metrics;
    final highlighted = widget.highlightedIndex == index;
    return DlmInteractive(
      role: DlmRole.menuItem,
      semanticLabel: item.label,
      focusNode: _node(index),
      autofocus:
          widget.autofocus && widget.highlightedIndex == null && isFirstEnabled,
      ensureHitTarget: false,
      onTap: item.onPressed == null ? null : () => _choose(item),
      builder: (context, states) => theme.components.menuItem(
        context,
        states: highlighted ? states.copyWith(hovered: true) : states,
        destructive: item.destructive,
        content: Row(
          children: [
            if (anyChecked)
              SizedBox(
                width: m.icon + m.spacing.sm,
                child: item.checked ?? false
                    ? const DlmIcon(DlmIconName.check)
                    : null,
              ),
            if (item.icon != null) ...[
              item.icon!,
              SizedBox(width: m.spacing.sm),
            ],
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.shortcut != null) ...[
              SizedBox(width: m.spacing.xl),
              Text(
                item.shortcut!,
                style: theme.typography.caption.copyWith(
                  color: states.hovered || states.focusVisible || highlighted
                      ? null
                      : theme.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A button that opens a menu below it.
class DlmMenuButton extends StatefulWidget {
  /// Creates a menu button.
  const DlmMenuButton({
    required this.entries,
    this.label,
    this.icon,
    this.semanticLabel,
    this.variant = DlmButtonVariant.secondary,
    this.size = DlmControlSize.regular,
    this.align = DlmPopoverAlign.start,
    super.key,
  }) : assert(
         label != null || semanticLabel != null,
         'An icon-only menu button needs a semanticLabel.',
       );

  /// The menu entries.
  final List<DlmMenuEntry> entries;

  /// Button text.
  final String? label;

  /// Button icon.
  final Widget? icon;

  /// Accessible name when there is no label.
  final String? semanticLabel;

  /// The emphasis of the button.
  final DlmButtonVariant variant;

  /// The height class of the button.
  final DlmControlSize size;

  /// Which edge of the button the menu aligns with.
  final DlmPopoverAlign align;

  @override
  State<DlmMenuButton> createState() => _DlmMenuButtonState();
}

class _DlmMenuButtonState extends State<DlmMenuButton> {
  final DlmPopoverController _controller = DlmPopoverController();

  @override
  Widget build(BuildContext context) {
    return DlmPopover(
      controller: _controller,
      align: widget.align,
      surface: false,
      popoverBuilder: (_) =>
          DlmMenuPanel(entries: widget.entries, onClose: _controller.hide),
      child: DlmButton(
        label: widget.label,
        icon: widget.icon,
        semanticLabel: widget.semanticLabel,
        variant: widget.variant,
        size: widget.size,
        onPressed: _controller.toggle,
      ),
    );
  }
}

/// A button with a main action and an attached arrow that opens a menu of
/// related actions.
class DlmSplitButton extends StatefulWidget {
  /// Creates a split button.
  const DlmSplitButton({
    required this.label,
    required this.onPressed,
    required this.entries,
    required this.menuLabel,
    this.variant = DlmButtonVariant.primary,
    super.key,
  });

  /// Text of the main action.
  final String label;

  /// The main action; null disables the main part.
  final VoidCallback? onPressed;

  /// The menu entries.
  final List<DlmMenuEntry> entries;

  /// Accessible name of the arrow (localised): "More options".
  final String menuLabel;

  /// The emphasis of both parts.
  final DlmButtonVariant variant;

  @override
  State<DlmSplitButton> createState() => _DlmSplitButtonState();
}

class _DlmSplitButtonState extends State<DlmSplitButton> {
  final DlmPopoverController _controller = DlmPopoverController();

  @override
  Widget build(BuildContext context) {
    final gap = DlmTheme.of(context).metrics.borderWidth;
    return DlmPopover(
      controller: _controller,
      align: DlmPopoverAlign.end,
      surface: false,
      popoverBuilder: (_) =>
          DlmMenuPanel(entries: widget.entries, onClose: _controller.hide),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DlmButton(
            label: widget.label,
            variant: widget.variant,
            onPressed: widget.onPressed,
          ),
          SizedBox(width: gap),
          DlmIconButton(
            icon: const DlmIcon(DlmIconName.chevronDown),
            semanticLabel: widget.menuLabel,
            variant: widget.variant,
            onPressed: _controller.toggle,
          ),
        ],
      ),
    );
  }
}

/// Opens [entries] as a context menu at the pointer on right click, and at the
/// centre of [child] on the Menu key or Shift+F10.
class DlmContextMenuRegion extends StatefulWidget {
  /// Creates a context menu region.
  const DlmContextMenuRegion({
    required this.entries,
    required this.child,
    super.key,
  });

  /// Builds the entries when the menu opens (so they reflect current state).
  final List<DlmMenuEntry> Function() entries;

  /// The content the menu belongs to.
  final Widget child;

  @override
  State<DlmContextMenuRegion> createState() => _DlmContextMenuRegionState();
}

class _DlmContextMenuRegionState extends State<DlmContextMenuRegion> {
  void _open(Offset global) =>
      showDlmContextMenu(context, global, widget.entries());

  void _openAtCentre() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    _open(box.localToGlobal(box.size.center(Offset.zero)));
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.contextMenu): _openAtCentre,
        const SingleActivator(LogicalKeyboardKey.f10, shift: true):
            _openAtCentre,
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapUp: (d) => _open(d.globalPosition),
        child: widget.child,
      ),
    );
  }
}

/// Shows [entries] as a context menu at [globalPosition] in the nearest
/// overlay. Focus returns to where it was when the menu closes.
void showDlmContextMenu(
  BuildContext context,
  Offset globalPosition,
  List<DlmMenuEntry> entries,
) {
  if (entries.isEmpty) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  final theme = DlmTheme.of(context);
  final previousFocus = FocusManager.instance.primaryFocus;
  late OverlayEntry entry;
  var closed = false;
  void close() {
    if (closed) return;
    closed = true;
    entry
      ..remove()
      ..dispose();
    if (previousFocus != null &&
        previousFocus.context != null &&
        previousFocus.canRequestFocus) {
      previousFocus.requestFocus();
    }
  }

  entry = OverlayEntry(
    builder: (overlayContext) {
      final screen = MediaQuery.sizeOf(overlayContext);
      return Stack(
        children: [
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => close(),
            ),
          ),
          CustomSingleChildLayout(
            delegate: _MenuPositionDelegate(globalPosition, screen),
            child: DlmTheme(
              data: theme,
              child: FocusScope(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape): close,
                  },
                  child: DlmMenuPanel(entries: entries, onClose: close),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  overlay.insert(entry);
}

class _MenuPositionDelegate extends SingleChildLayoutDelegate {
  const _MenuPositionDelegate(this.position, this.screen);

  final Offset position;
  final Size screen;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(Size(screen.width - 16, screen.height - 16));

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = (position.dx + childSize.width > screen.width - 8)
        ? (position.dx - childSize.width).clamp(8, screen.width)
        : position.dx;
    final y = (position.dy + childSize.height > screen.height - 8)
        ? (screen.height - childSize.height - 8).clamp(8, screen.height)
        : position.dy;
    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  bool shouldRelayout(_MenuPositionDelegate old) =>
      old.position != position || old.screen != screen;
}
