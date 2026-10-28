import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Detects a double click without delaying the first click.
///
/// A `GestureDetector` with both `onTap` and `onDoubleTap` holds every single
/// click back until the double-click timeout passes, which makes lists feel
/// laggy. This widget only watches pointer-down events: the second primary
/// press within [kDoubleTapTimeout] and [kDoubleTapSlop] of the first calls
/// [onDoubleClick], while ordinary tap handling is unaffected.
class DlmDoubleClick extends StatefulWidget {
  /// Creates a double-click detector around [child].
  const DlmDoubleClick({
    required this.onDoubleClick,
    required this.child,
    super.key,
  });

  /// Called on the second press of a double click.
  final VoidCallback? onDoubleClick;

  /// The content.
  final Widget child;

  @override
  State<DlmDoubleClick> createState() => _DlmDoubleClickState();
}

class _DlmDoubleClickState extends State<DlmDoubleClick> {
  Timer? _window;
  Offset? _first;

  void _down(PointerDownEvent e) {
    if (widget.onDoubleClick == null || e.buttons != kPrimaryButton) return;
    final first = _first;
    if (_window != null &&
        first != null &&
        (e.position - first).distance <= kDoubleTapSlop) {
      _reset();
      widget.onDoubleClick!();
      return;
    }
    _window?.cancel();
    _first = e.position;
    _window = Timer(kDoubleTapTimeout, _reset);
  }

  void _reset() {
    _window?.cancel();
    _window = null;
    _first = null;
  }

  @override
  void dispose() {
    _window?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _down,
      child: widget.child,
    );
  }
}
