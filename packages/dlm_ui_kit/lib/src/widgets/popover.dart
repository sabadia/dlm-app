import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Opens and closes a [DlmPopover]; created and owned by the widget that
/// triggers it.
class DlmPopoverController {
  final OverlayPortalController _portal = OverlayPortalController();
  FocusNode? _returnFocus;

  /// Whether the popover is open.
  bool get isShowing => _portal.isShowing;

  /// Opens the popover, remembering the focused control to restore later.
  void show() {
    if (isShowing) return;
    _returnFocus = FocusManager.instance.primaryFocus;
    _portal.show();
  }

  /// Closes the popover and gives focus back to the control that had it.
  void hide() {
    if (!isShowing) return;
    _portal.hide();
    final node = _returnFocus;
    _returnFocus = null;
    if (node != null && node.context != null && node.canRequestFocus) {
      node.requestFocus();
    }
  }

  /// Opens a closed popover and closes an open one.
  void toggle() => isShowing ? hide() : show();
}

/// Which edge of the anchor the popover lines up with.
enum DlmPopoverAlign {
  /// Left edges line up (right in right-to-left layouts).
  start,

  /// Right edges line up.
  end,
}

/// Shows [popoverBuilder] in a floating surface next to [child], below it or
/// above when there is no room. Clicking outside or pressing Escape closes it
/// and returns focus to where it was.
class DlmPopover extends StatefulWidget {
  /// Creates a popover anchored to [child].
  const DlmPopover({
    required this.controller,
    required this.child,
    required this.popoverBuilder,
    this.align = DlmPopoverAlign.start,
    this.matchAnchorWidth = false,
    this.maxHeight = 360,
    this.surface = true,
    this.onDismissed,
    super.key,
  });

  /// Opens and closes the popover.
  final DlmPopoverController controller;

  /// The anchor.
  final Widget child;

  /// Builds the popover content.
  final WidgetBuilder popoverBuilder;

  /// Which edge of the anchor the popover aligns with.
  final DlmPopoverAlign align;

  /// Make the popover at least as wide as the anchor.
  final bool matchAnchorWidth;

  /// The tallest the popover may be.
  final double maxHeight;

  /// Wrap the content in the skin's popover surface; menus bring their own.
  final bool surface;

  /// Called after the user dismissed the popover by clicking outside or
  /// pressing Escape.
  final VoidCallback? onDismissed;

  @override
  State<DlmPopover> createState() => _DlmPopoverState();
}

class _DlmPopoverState extends State<DlmPopover> {
  final LayerLink _link = LayerLink();

  void _dismiss() {
    widget.controller.hide();
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: widget.controller._portal,
        overlayChildBuilder: _overlay,
        child: widget.child,
      ),
    );
  }

  Widget _overlay(BuildContext overlayContext) {
    final theme = DlmTheme.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final screen = MediaQuery.sizeOf(overlayContext);
    var below = true;
    var room = widget.maxHeight;
    double? anchorWidth;
    if (box != null && box.hasSize) {
      final top = box.localToGlobal(Offset.zero).dy;
      final spaceBelow = screen.height - top - box.size.height;
      final spaceAbove = top;
      below = spaceBelow >= widget.maxHeight || spaceBelow >= spaceAbove;
      room = (below ? spaceBelow : spaceAbove) - 16;
      anchorWidth = box.size.width;
    }
    final gap = theme.metrics.spacing.xs;
    final end = widget.align == DlmPopoverAlign.end;
    Widget content = Builder(builder: widget.popoverBuilder);
    if (widget.surface) {
      content = theme.components.popoverSurface(overlayContext, child: content);
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _dismiss(),
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: below
              ? (end ? Alignment.bottomRight : Alignment.bottomLeft)
              : (end ? Alignment.topRight : Alignment.topLeft),
          followerAnchor: below
              ? (end ? Alignment.topRight : Alignment.topLeft)
              : (end ? Alignment.bottomRight : Alignment.bottomLeft),
          offset: Offset(0, below ? gap : -gap),
          child: Align(
            alignment: below
                ? (end ? Alignment.topRight : Alignment.topLeft)
                : (end ? Alignment.bottomRight : Alignment.bottomLeft),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.matchAnchorWidth ? (anchorWidth ?? 0) : 0,
                maxHeight: room.clamp(80, widget.maxHeight),
                maxWidth: screen.width - 16,
              ),
              child: DlmTheme(
                data: theme,
                child: FocusScope(
                  child: CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.escape):
                          _dismiss,
                    },
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
