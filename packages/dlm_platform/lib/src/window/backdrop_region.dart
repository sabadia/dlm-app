import 'dart:async';

import 'package:flutter/widgets.dart';

import 'window_chrome.dart';

/// Tells the native window where its backdrop effect (the blurred sidebar) is:
/// the area this widget occupies. Place it around the sidebar; the effect
/// follows it when the sidebar is resized or the window changes size.
class BackdropRegion extends StatefulWidget {
  /// Creates a backdrop region around [child].
  const BackdropRegion({required this.chrome, required this.child, super.key});

  /// The window chrome to inform.
  final WindowChrome chrome;

  /// The content, typically the sidebar.
  final Widget child;

  @override
  State<BackdropRegion> createState() => _BackdropRegionState();
}

class _BackdropRegionState extends State<BackdropRegion> {
  Rect? _reported;
  bool _scheduled = false;

  void _report() {
    _scheduled = false;
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (rect == _reported) return;
    _reported = rect;
    unawaited(_send(rect));
  }

  Future<void> _send(Rect? rect) async {
    try {
      await widget.chrome.setBackdropRegion(rect);
    } on WindowChromeException {
      // The window is not ready; the next layout reports again.
      _reported = null;
    }
  }

  @override
  void dispose() {
    unawaited(_send(null));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-measure after every layout of this subtree.
    if (!_scheduled) {
      _scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _report());
    }
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        if (!_scheduled) {
          _scheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _report());
        }
        return false;
      },
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }
}
