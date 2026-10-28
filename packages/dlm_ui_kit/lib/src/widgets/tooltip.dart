import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Shows [message] in a bubble under [child] when the pointer rests on it or
/// it has keyboard focus. The message is also its semantic tooltip.
class DlmTooltip extends StatefulWidget {
  /// Creates a tooltip.
  const DlmTooltip({
    required this.message,
    required this.child,
    this.showDelay = const Duration(milliseconds: 600),
    super.key,
  });

  /// The text.
  final String message;

  /// The control the tooltip describes.
  final Widget child;

  /// How long the pointer must rest before the bubble appears.
  final Duration showDelay;

  @override
  State<DlmTooltip> createState() => _DlmTooltipState();
}

class _DlmTooltipState extends State<DlmTooltip> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  Timer? _timer;

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(widget.showDelay, _show);
  }

  void _show() {
    if (mounted && !_portal.isShowing) _portal.show();
  }

  void _hide() {
    _timer?.cancel();
    if (_portal.isShowing) _portal.hide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: widget.message,
      child: MouseRegion(
        onEnter: (_) => _schedule(),
        onExit: (_) => _hide(),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _hide(),
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (focused) {
              if (!focused) {
                _hide();
              } else if (FocusManager.instance.highlightMode ==
                  FocusHighlightMode.traditional) {
                _show();
              }
            },
            child: CompositedTransformTarget(
              link: _link,
              child: OverlayPortal(
                controller: _portal,
                overlayChildBuilder: (context) {
                  final theme = DlmTheme.of(this.context);
                  return CompositedTransformFollower(
                    link: _link,
                    targetAnchor: Alignment.bottomCenter,
                    followerAnchor: Alignment.topCenter,
                    offset: Offset(0, theme.metrics.spacing.xs),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: DlmTheme(
                            data: theme,
                            child: theme.components.tooltipBubble(
                              context,
                              content: Text(widget.message),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
