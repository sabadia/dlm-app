import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/widgets.dart';

/// Takes files dragged in from the file manager or a browser and tells which
/// paths were dropped. While something is dragged over it draws a [highlight]
/// frame over the child.
class DropZone extends StatefulWidget {
  /// Wraps [child]; [onDrop] gets the paths of the dropped files.
  const DropZone({
    required this.onDrop,
    required this.child,
    this.highlight = const Color(0xFF0A84FF),
    super.key,
  });

  /// Called with the paths of the dropped files, folders included.
  final void Function(List<String> paths) onDrop;

  /// What the zone covers.
  final Widget child;

  /// The colour of the frame shown during a drag.
  final Color highlight;

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _over = false;

  @override
  Widget build(BuildContext context) => DropTarget(
    onDragEntered: (_) => setState(() => _over = true),
    onDragExited: (_) => setState(() => _over = false),
    onDragDone: (details) {
      setState(() => _over = false);
      final paths = [
        for (final f in details.files)
          if (f.path.isNotEmpty) f.path,
      ];
      if (paths.isNotEmpty) widget.onDrop(paths);
    },
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (_over)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: widget.highlight, width: 3),
                  color: widget.highlight.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
