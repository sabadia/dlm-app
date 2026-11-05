import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// What the window shows while the download service starts: the app's icon and
/// name, a slow progress bar and what is being waited for. It fades in, so a
/// quick start never shows a flash of it.
class StartupSplash extends StatelessWidget {
  /// Creates the splash; [message] says what is being waited for.
  const StartupSplash({required this.message, super.key});

  /// What is happening, such as "Starting This computer…".
  final String message;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = DlmTheme.of(context);
    final c = t.colors;
    return Semantics(
      liveRegion: true,
      label: '${l.connection_connecting_title}. $message',
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icon/dlm_128.png', width: 88, height: 88),
                  SizedBox(height: t.metrics.spacing.md),
                  Text(
                    l.app_name,
                    style: t.typography.title.copyWith(color: c.textPrimary),
                  ),
                  SizedBox(height: t.metrics.spacing.lg),
                  SizedBox(
                    width: 160,
                    child: DlmProgressBar(
                      value: null,
                      tone: DlmTone.accent,
                      semanticLabel: l.connection_connecting_title,
                    ),
                  ),
                  SizedBox(height: t.metrics.spacing.md),
                  Text(
                    l.connection_connecting_title,
                    textAlign: TextAlign.center,
                    style: t.typography.body.copyWith(color: c.textPrimary),
                  ),
                  SizedBox(height: t.metrics.spacing.xs),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: t.typography.caption.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
