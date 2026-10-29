import 'dart:async';

import 'package:flutter/widgets.dart';

import '../components/components.dart';
import '../theme/shell.dart';
import '../theme/theme.dart';
import 'banner.dart';
import 'button.dart';
import 'icon.dart';

/// A transient message.
class DlmToast {
  /// Creates a toast; [dismissLabel] is the accessible name of its close
  /// button and must be localised by the caller.
  const DlmToast({
    required this.message,
    required this.dismissLabel,
    this.tone = DlmTone.info,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 6),
  }) : assert(
         onAction == null || actionLabel != null,
         'An action needs a localised actionLabel.',
       );

  /// The message.
  final String message;

  /// Accessible name of the dismiss button.
  final String dismissLabel;

  /// The meaning, which sets colour and icon.
  final DlmTone tone;

  /// Text of the optional action button.
  final String? actionLabel;

  /// Called when the action is pressed; the toast is then dismissed.
  final VoidCallback? onAction;

  /// How long the toast stays; errors and toasts with an action should be
  /// longer. Zero keeps it until dismissed.
  final Duration duration;
}

/// Holds the toasts that are showing. Provided by the app; features call
/// [show].
class DlmToastController extends ChangeNotifier {
  int _next = 0;
  final List<(int, DlmToast)> _items = [];

  /// The toasts currently showing, oldest first.
  List<DlmToast> get toasts => [for (final (_, t) in _items) t];

  /// Shows [toast] and returns an id for [dismiss].
  int show(DlmToast toast) {
    final id = _next++;
    _items.add((id, toast));
    notifyListeners();
    return id;
  }

  /// Removes the toast with [id] if it is still showing.
  void dismiss(int id) {
    final before = _items.length;
    _items.removeWhere((e) => e.$1 == id);
    if (_items.length != before) notifyListeners();
  }
}

/// Places the toasts of [controller] over [child], at the corner or edge the
/// skin's shell pattern prescribes. At most [maxVisible] show at once.
class DlmToastHost extends StatelessWidget {
  /// Creates the host.
  const DlmToastHost({
    required this.controller,
    required this.child,
    this.maxVisible = 3,
    super.key,
  });

  /// The toasts to show.
  final DlmToastController controller;

  /// The app content.
  final Widget child;

  /// How many toasts show at once; older ones wait.
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final alignment = switch (theme.shell.feedback) {
      DlmFeedbackStyle.floatingBanner => Alignment.topRight,
      DlmFeedbackStyle.infoBar => Alignment.bottomRight,
      DlmFeedbackStyle.toastOverlay => Alignment.bottomCenter,
      DlmFeedbackStyle.inlineMessage => Alignment.bottomRight,
    };
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final items = controller._items.take(maxVisible).toList();
              return Padding(
                padding: EdgeInsets.all(theme.metrics.spacing.lg),
                child: Align(
                  alignment: alignment,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      verticalDirection: alignment.y < 0
                          ? VerticalDirection.down
                          : VerticalDirection.up,
                      children: [
                        for (final (id, toast) in items)
                          Padding(
                            key: ValueKey(id),
                            padding: EdgeInsets.only(
                              top: theme.metrics.spacing.sm,
                            ),
                            child: _ToastView(
                              toast: toast,
                              onDismiss: () => controller.dismiss(id),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.toast, required this.onDismiss});

  final DlmToast toast;
  final VoidCallback onDismiss;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  Timer? _timer;
  bool _hovered = false;
  bool _focusWithin = false;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  void _arm() {
    _timer?.cancel();
    if (widget.toast.duration > Duration.zero) {
      _timer = Timer(widget.toast.duration, widget.onDismiss);
    }
  }

  void _holdOrRelease() {
    if (_hovered || _focusWithin) {
      _timer?.cancel();
    } else {
      _arm();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final t = widget.toast;
    final gap = SizedBox(width: theme.metrics.spacing.md);
    return MouseRegion(
      onEnter: (_) {
        _hovered = true;
        _holdOrRelease();
      },
      onExit: (_) {
        _hovered = false;
        _holdOrRelease();
      },
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (f) {
          _focusWithin = f;
          _holdOrRelease();
        },
        child: Semantics(
          container: true,
          liveRegion: true,
          child: theme.components.toast(
            context,
            tone: t.tone,
            content: Row(
              children: [
                DlmIcon(dlmToneIcon(t.tone)),
                gap,
                Expanded(child: Text(t.message)),
                if (t.onAction != null) ...[
                  gap,
                  DlmButton(
                    label: t.actionLabel,
                    size: DlmControlSize.small,
                    onPressed: () {
                      t.onAction!();
                      widget.onDismiss();
                    },
                  ),
                ],
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.close),
                  semanticLabel: t.dismissLabel,
                  size: DlmControlSize.small,
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
