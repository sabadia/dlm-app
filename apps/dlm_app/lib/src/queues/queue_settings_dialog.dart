import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../shell/feedback.dart';
import 'queue_settings_draft.dart';

/// Whether the dialog offers the quota, the speed profiles and the action at
/// the end of the queue. The daemon refuses to save those three today (its
/// request validation rejects them, dlm-server#128), so they stay out of reach
/// until that is fixed; then this becomes `true` and the provider goes away.
final queueLimitsEditableProvider = Provider<bool>((ref) => false);

/// Opens the settings of [queue] (schedule, speed, quota, what happens at the
/// end) and saves them when the user confirms.
Future<void> showQueueSettings(
  BuildContext context,
  WidgetRef ref,
  Queue queue,
) async {
  final l = AppLocalizations.of(context);
  final draft = await showDlmDialog<QueueSettingsDraft>(
    context,
    semanticLabel: l.qs_title(queue.name),
    builder: (_) => QueueSettingsDialog(queue: queue),
  );
  if (draft == null || !context.mounted) return;
  try {
    await ref
        .read(queuesProvider.notifier)
        .replaceSettings(queue.id, draft.applyTo(queue.settings));
    if (context.mounted) {
      showNotice(context, ref, l.toast_queue_saved(queue.name));
    }
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// A size as text that [parseSize] reads back to the same number of bytes.
String sizeText(int bytes) {
  const units = [
    (1 << 40, 'T'),
    (1 << 30, 'G'),
    (1 << 20, 'M'),
    (1 << 10, 'K'),
  ];
  for (final (factor, letter) in units) {
    if (bytes >= factor && bytes % factor == 0) {
      return '${bytes ~/ factor} $letter';
    }
  }
  return '$bytes';
}

/// The content of the queue settings dialog; pops the edited
/// [QueueSettingsDraft].
class QueueSettingsDialog extends ConsumerStatefulWidget {
  /// Creates the dialog for [queue].
  const QueueSettingsDialog({required this.queue, super.key});

  /// The queue being edited.
  final Queue queue;

  @override
  ConsumerState<QueueSettingsDialog> createState() =>
      _QueueSettingsDialogState();
}

class _QueueSettingsDialogState extends ConsumerState<QueueSettingsDialog> {
  late final QueueSettingsDraft _draft = QueueSettingsDraft.from(
    widget.queue.settings,
  );
  late final TextEditingController _args = TextEditingController(
    text: _draft.args.join('\n'),
  );

  late final TextEditingController _command = TextEditingController(
    text: _draft.command,
  );

  @override
  void dispose() {
    _command.dispose();
    _args.dispose();
    super.dispose();
  }

  void _change(VoidCallback edit) => setState(edit);

  List<String> _dayLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    // 1 January 2024 was a Monday, the first row of the grid.
    return [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(DateTime(2024, 1, 1 + i)),
    ];
  }

  Widget _grid(BuildContext context, WindowsDraft windows, String label) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: windows.exact
          ? DlmScheduleGrid(
              cells: windows.cells,
              dayLabels: _dayLabels(context),
              slotLabel: (slot) => '${slot.toString().padLeft(2, '0')}:00',
              semanticLabel: label,
              onChanged: (cells) => _change(() {
                windows.cells
                  ..clear()
                  ..addAll(cells);
              }),
            )
          : DlmBanner(
              message: l.qs_schedule_custom,
              actionLabel: l.qs_schedule_use_grid,
              onAction: () =>
                  _change(() => windows.useGrid(windows.toWindows())),
            ),
    );
  }

  Widget _sizeField(
    AppLocalizations l, {
    required int? value,
    required ValueChanged<int?> onChanged,
    required String label,
    String? placeholder,
  }) => SizedBox(
    width: 180,
    child: DlmParsedField<int>(
      value: value,
      allowEmpty: true,
      parse: parseSize,
      format: sizeText,
      invalidText: l.qs_invalid_size,
      semanticLabel: label,
      placeholder: placeholder,
      onChanged: (v) => _change(() => onChanged(v)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final gap = SizedBox(height: theme.metrics.spacing.lg);
    final d = _draft;
    final limits = ref.watch(queueLimitsEditableProvider);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.qs_intro,
          style: theme.typography.body.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        gap,
        DlmFormGroup(
          title: l.qs_group_speed,
          children: [
            DlmFormRow(
              label: l.qs_speed_limit,
              description: l.qs_speed_limit_desc,
              control: _sizeField(
                l,
                value: d.speedLimit,
                label: l.qs_speed_limit,
                placeholder: l.qs_speed_placeholder,
                onChanged: (v) => d.speedLimit = v,
              ),
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.qs_group_schedule,
          children: [
            DlmFormRow(
              label: l.qs_schedule_on,
              description: l.qs_schedule_desc,
              control: DlmSwitch(
                value: d.scheduleOn,
                semanticLabel: l.qs_schedule_on,
                onChanged: (v) => _change(() => d.scheduleOn = v),
              ),
            ),
            if (d.scheduleOn) _grid(context, d.schedule, l.qs_schedule_grid),
          ],
        ),
        if (limits) ...[
          gap,
          DlmFormGroup(
            title: l.qs_group_profiles,
            footer: l.qs_profiles_desc,
            children: [
              for (var i = 0; i < d.profiles.length; i++) ...[
                DlmFormRow(
                  label: l.qs_profile_title(i + 1),
                  description: l.qs_profile_unlimited,
                  control: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sizeField(
                        l,
                        value: d.profiles[i].speedLimit,
                        label: l.qs_profile_limit,
                        onChanged: (v) => d.profiles[i].speedLimit = v,
                      ),
                      SizedBox(width: theme.metrics.spacing.sm),
                      DlmIconButton(
                        icon: const DlmIcon(DlmIconName.trash),
                        semanticLabel: l.qs_profile_remove,
                        onPressed: () => _change(() => d.profiles.removeAt(i)),
                      ),
                    ],
                  ),
                ),
                _grid(
                  context,
                  d.profiles[i].windows,
                  '${l.qs_profile_title(i + 1)} · ${l.qs_schedule_grid}',
                ),
              ],
              Padding(
                padding: EdgeInsets.all(theme.metrics.spacing.md),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DlmButton(
                    label: l.qs_profile_add,
                    icon: const DlmIcon(DlmIconName.plus),
                    onPressed: () => _change(
                      () =>
                          d.profiles.add(ProfileDraft(windows: WindowsDraft())),
                    ),
                  ),
                ),
              ),
            ],
          ),
          gap,
          DlmFormGroup(
            title: l.qs_group_quota,
            children: [
              DlmFormRow(
                label: l.qs_quota_on,
                description: l.qs_quota_desc,
                control: DlmSwitch(
                  value: d.quotaOn,
                  semanticLabel: l.qs_quota_on,
                  onChanged: (v) => _change(() => d.quotaOn = v),
                ),
              ),
              if (d.quotaOn) ...[
                DlmFormRow(
                  label: l.qs_quota_bytes,
                  control: _sizeField(
                    l,
                    value: d.quotaBytes,
                    label: l.qs_quota_bytes,
                    onChanged: (v) => d.quotaBytes = v,
                  ),
                ),
                DlmFormRow(
                  label: l.qs_quota_period,
                  control: SizedBox(
                    width: 180,
                    child: DlmParsedField<Duration>(
                      value: d.quotaPeriod,
                      allowEmpty: true,
                      parse: parseDuration,
                      format: formatDuration,
                      invalidText: l.qs_invalid_duration,
                      semanticLabel: l.qs_quota_period,
                      placeholder: l.qs_quota_period_placeholder,
                      onChanged: (v) => _change(() => d.quotaPeriod = v),
                    ),
                  ),
                ),
              ],
            ],
          ),
          gap,
          DlmFormGroup(
            title: l.qs_group_after,
            children: [
              DlmFormRow(
                label: l.qs_after,
                control: DlmDropdown<QueueFinish>(
                  semanticLabel: l.qs_after,
                  value: d.finish,
                  choices: [
                    DlmChoice(value: QueueFinish.none, label: l.qs_after_none),
                    DlmChoice(value: QueueFinish.stop, label: l.qs_after_stop),
                    DlmChoice(
                      value: QueueFinish.sleep,
                      label: l.qs_after_sleep,
                    ),
                    DlmChoice(
                      value: QueueFinish.shutdown,
                      label: l.qs_after_shutdown,
                    ),
                    DlmChoice(
                      value: QueueFinish.command,
                      label: l.qs_after_command,
                    ),
                  ],
                  onChanged: (v) => _change(() => d.finish = v),
                ),
              ),
              if (d.finish != QueueFinish.none)
                DlmFormRow(
                  label: l.qs_after_delay,
                  description: l.qs_after_delay_desc,
                  control: SizedBox(
                    width: 180,
                    child: DlmParsedField<Duration>(
                      value: d.finishDelay,
                      allowEmpty: true,
                      parse: parseDuration,
                      format: formatDuration,
                      invalidText: l.qs_invalid_duration,
                      semanticLabel: l.qs_after_delay,
                      onChanged: (v) => _change(() => d.finishDelay = v),
                    ),
                  ),
                ),
              if (d.finish == QueueFinish.command) ...[
                DlmFormRow(
                  label: l.qs_after_command_path,
                  control: SizedBox(
                    width: 260,
                    child: DlmTextField(
                      semanticLabel: l.qs_after_command_path,
                      controller: _command,
                      errorText:
                          d.command.trim().isEmpty ||
                              QueueSettingsDraft.isAbsolutePath(
                                d.command.trim(),
                              )
                          ? null
                          : l.qs_invalid_path,
                      onChanged: (v) => _change(() => d.command = v),
                    ),
                  ),
                ),
                DlmFormRow(
                  label: l.qs_after_command_args,
                  control: SizedBox(
                    width: 260,
                    child: DlmTextField(
                      semanticLabel: l.qs_after_command_args,
                      controller: _args,
                      maxLines: 3,
                      minLines: 2,
                      onChanged: (v) => _change(() {
                        d.args
                          ..clear()
                          ..addAll(
                            v.split('\n').where((a) => a.trim().isNotEmpty),
                          );
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(theme.metrics.spacing.md),
                  child: DlmBanner(
                    tone: DlmTone.warning,
                    message: l.qs_after_command_warning,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 620,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: DlmDialogContent(
        title: l.qs_title(widget.queue.name),
        child: Flexible(child: SingleChildScrollView(child: body)),
        actions: [
          DlmButton(
            label: l.qs_cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DlmButton(
            label: l.queue_save,
            variant: DlmButtonVariant.primary,
            onPressed: d.valid ? () => Navigator.of(context).pop(d) : null,
          ),
        ],
      ),
    );
  }
}
