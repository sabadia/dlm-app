import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feedback.dart';
import 'status_banners.dart';

/// How long "turbo" lifts the speed limit when it is switched on.
const int turboMinutes = 60;

/// The strip at the bottom of the window: the connection, the speeds, how many
/// downloads run and wait, the quota, the turbo switch and pause/resume all.
class StatusBar extends ConsumerWidget {
  /// Creates the bar.
  const StatusBar({super.key});

  Future<void> _all(
    BuildContext context,
    WidgetRef ref, {
    required bool pause,
  }) async {
    final l = AppLocalizations.of(context);
    try {
      final actions = ref.read(taskActionsProvider);
      final results = await (pause ? actions.pauseAll() : actions.resumeAll());
      if (!context.mounted) return;
      final ok = results.where((r) => r.ok).length;
      showNotice(
        context,
        ref,
        pause ? l.toast_paused(ok) : l.toast_resumed(ok),
      );
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _turbo(
    BuildContext context,
    WidgetRef ref, {
    required bool on,
  }) async {
    try {
      final limits = ref.read(limitsProvider.notifier);
      await (on ? limits.turbo(turboMinutes) : limits.endTurbo());
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final speed = ref.watch(systemSpeedProvider);
    final limits = ref.watch(limitsProvider).value;
    final hub = ref.watch(hubStateProvider).value;
    final gap = theme.metrics.spacing.md;
    final caption = theme.typography.caption.copyWith(
      color: theme.colors.textSecondary,
    );

    final turboOn = limits?.override != null;
    final quota = limits?.global.quota;
    final connected =
        hub == null ||
        hub == HubConnectionState.connected ||
        hub == HubConnectionState.connecting;

    final items = <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? theme.colors.success : theme.colors.warning,
            ),
          ),
          SizedBox(width: theme.metrics.spacing.xs),
          Text(
            connected ? l.status_connected : l.status_reconnecting,
            style: caption,
          ),
        ],
      ),
      Text(
        l.status_speed(
          formatSpeed(speed?.down ?? 0) ?? '0',
          formatSpeed(speed?.up ?? 0) ?? '0',
        ),
        style: caption,
      ),
      Text(
        l.status_counts(speed?.active ?? 0, speed?.queued ?? 0),
        style: caption,
      ),
      if (quota != null && quota.bytes > 0)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 90,
              child: DlmProgressBar(
                value: (quota.used / quota.bytes).clamp(0.0, 1.0),
                tone: quota.exhausted ? DlmTone.danger : DlmTone.accent,
                semanticLabel: l.status_quota_label,
              ),
            ),
            SizedBox(width: theme.metrics.spacing.xs),
            Text(
              l.status_quota(
                formatBytes(quota.used) ?? '0',
                formatBytes(quota.bytes) ?? '0',
              ),
              style: caption,
            ),
          ],
        ),
    ];

    return Semantics(
      container: true,
      label: l.status_label,
      child: ColoredBox(
        color: theme.colors.raised,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: gap,
            vertical: theme.metrics.spacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: gap,
                  runSpacing: theme.metrics.spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: items,
                ),
              ),
              DlmButton(
                label: turboOn ? l.status_turbo_on : l.status_turbo,
                icon: const DlmIcon(DlmIconName.speed),
                variant: turboOn
                    ? DlmButtonVariant.primary
                    : DlmButtonVariant.plain,
                onPressed: limits == null
                    ? null
                    : () => unawaited(_turbo(context, ref, on: !turboOn)),
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.pause),
                semanticLabel: l.status_pause_all,
                onPressed: () => unawaited(_all(context, ref, pause: true)),
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.play),
                semanticLabel: l.status_resume_all,
                onPressed: () => unawaited(_all(context, ref, pause: false)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
