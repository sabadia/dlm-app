import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format/dlm_format.dart';
import 'task_cells.dart';
import 'task_format.dart';

/// The height of a card row, and of a row in the compact density.
double taskCardExtent({required bool compact}) => compact ? 88 : 100;

/// A download as a card: its name and status, the progress, and the numbers as
/// small chips. It follows the live task, so a progress tick repaints only the
/// card.
class TaskCard extends StatelessWidget {
  /// Creates the card of [task]; [states] come from the list.
  const TaskCard({required this.task, required this.states, super.key});

  /// The task the list holds.
  final Task task;

  /// Hover, selection and focus of the row.
  final DlmStates states;

  @override
  Widget build(BuildContext context) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    final m = t.metrics;
    final selected = states.selected;
    final fill = selected
        ? (states.focused ? c.selection : c.selectionInactive)
        : states.hovered
        ? Color.alphaBlend(c.textPrimary.withValues(alpha: 0.04), c.raised)
        : c.raised;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DlmFocusRing(
        visible: states.focusVisible,
        radius: m.radii.container,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(m.radii.container),
            // Selection is the fill only; the hairline is for resting cards.
            border: selected
                ? null
                : Border.all(color: c.separator, width: m.borderWidth),
            boxShadow: selected || c.highContrast
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            // Never scrolls: when text is scaled up past what fits, the end of
            // the card is cut rather than overflowing.
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: TaskCell(
                  id: task.id,
                  builder: (context, live, progress) =>
                      _CardBody(task: live, progress: progress),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.task, required this.progress});

  final Task task;
  final ProgressData? progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = DlmTheme.of(context);
    final c = t.colors;
    final kind = task.statusKind;
    final downloaded = progress?.downloaded ?? task.downloaded;
    final size = progress?.size ?? task.size;
    final finished = kind == TaskStatus.completed;
    final fraction = size > 0 ? (downloaded / size).clamp(0.0, 1.0) : null;
    final speed = kind.isActive && progress != null && progress!.speed > 0
        ? context.speed(progress!.speed)
        : null;
    final left = kind.isActive && progress != null
        ? estimateRemaining(
            downloaded: progress!.downloaded,
            size: progress!.size,
            bytesPerSecond: progress!.speed,
          )
        : null;
    final sizeText = context.bytes(size);
    final done = finished ? 1.0 : fraction;
    final chips = <String>[
      if (sizeText != null && (finished || downloaded <= 0)) sizeText,
      if (sizeText != null && !finished && downloaded > 0)
        '${context.bytes(downloaded) ?? '0'} / $sizeText',
      if (speed != null) speed,
      if (left != null) formatDuration(left),
      if (task.engine != null && task.engine!.isNotEmpty) task.engine!,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                taskTitle(l, task),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.typography.bodyStrong.copyWith(color: c.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            DlmBadge(label: statusLabel(l, kind), tone: statusTone(kind)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DlmProgressBar(
                value: done,
                tone: switch (kind) {
                  TaskStatus.completed => DlmTone.success,
                  TaskStatus.error => DlmTone.danger,
                  _ => DlmTone.accent,
                },
                semanticLabel: taskTitle(l, task),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                done == null ? '' : '${(done * 100).floor()}%',
                textAlign: TextAlign.end,
                style: t.typography.caption.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRect(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final text in chips) _Chip(text),
              QueueChip(id: task.queueId),
              CategoryChip(name: taskTitle(l, task)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DlmTheme.of(context);
    final c = t.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(t.metrics.radii.small),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.typography.caption.copyWith(color: c.textSecondary),
        ),
      ),
    );
  }
}

/// The queue of a download as a chip.
class QueueChip extends ConsumerWidget {
  /// Creates the chip of queue [id].
  const QueueChip({required this.id, super.key});

  /// The queue id.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _Chip(ref.watch(queueProvider(id))?.name ?? id);
}

/// The category a download's file name falls under, as a chip; nothing when
/// no category matches.
class CategoryChip extends ConsumerWidget {
  /// Creates the chip for a download named [name].
  const CategoryChip({required this.name, super.key});

  /// The file name.
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final found = categoryOfFile(categories, name);
    return found == null ? const SizedBox.shrink() : _Chip(found);
  }
}
