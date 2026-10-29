import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// Progress, badges, chips, list rows and the empty/error/loading states.
class DisplaySection extends StatefulWidget {
  /// Creates the section.
  const DisplaySection({super.key});

  @override
  State<DisplaySection> createState() => _DisplaySectionState();
}

class _DisplaySectionState extends State<DisplaySection> {
  int _row = 1;
  bool _chip = true;

  @override
  Widget build(BuildContext context) {
    final gap = DlmTheme.of(context).metrics.spacing.lg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 420,
          child: Column(
            children: [
              const DlmProgressBar(value: 0.62, semanticLabel: 'Download'),
              SizedBox(height: gap / 2),
              const DlmProgressBar(
                value: 1,
                tone: DlmTone.success,
                semanticLabel: 'Done',
              ),
              SizedBox(height: gap / 2),
              const DlmProgressBar(
                value: 0.3,
                tone: DlmTone.danger,
                semanticLabel: 'Failed',
              ),
              SizedBox(height: gap / 2),
              const DlmProgressBar(value: null, semanticLabel: 'Resolving'),
            ],
          ),
        ),
        SizedBox(height: gap),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DlmProgressRing(value: 0.65, size: 28),
            SizedBox(width: 16),
            DlmProgressRing(value: null, size: 28),
          ],
        ),
        SizedBox(height: gap),
        Wrap(
          spacing: gap / 2,
          runSpacing: gap / 2,
          children: [
            for (final t in DlmTone.values) DlmBadge(label: t.name, tone: t),
            DlmChip(
              label: 'Video',
              selected: _chip,
              onSelected: (v) => setState(() => _chip = v),
            ),
            DlmChip(label: 'Audio', onSelected: (_) {}),
            DlmChip(
              label: 'Removable',
              onDeleted: () {},
              deleteLabel: 'Remove',
              selected: true,
              onSelected: (_) {},
            ),
          ],
        ),
        SizedBox(height: gap),
        SizedBox(
          width: 520,
          child: Column(
            children: [
              for (var i = 0; i < 3; i++)
                DlmListRow(
                  title: [
                    'ubuntu-26.04.iso',
                    'Big Buck Bunny.mkv',
                    'archive.tar.zst',
                  ][i],
                  subtitle: [
                    '4.7 GB · 62%',
                    '276 MB · Completed',
                    '1.2 GB · Failed',
                  ][i],
                  leading: const DlmIcon(DlmIconName.info),
                  trailing: DlmBadge(
                    label: ['Active', 'Done', 'Failed'][i],
                    tone: [DlmTone.accent, DlmTone.success, DlmTone.danger][i],
                  ),
                  selected: _row == i,
                  onTap: () => setState(() => _row = i),
                ),
            ],
          ),
        ),
        SizedBox(height: gap),
        const SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(
                child: DlmEmptyState(
                  title: 'No downloads',
                  message: 'Paste a link to start.',
                  icon: DlmIcon(DlmIconName.search),
                ),
              ),
              Expanded(
                child: DlmErrorState(
                  title: 'Could not load',
                  message: 'The daemon did not answer.',
                  retryLabel: 'Try again',
                  onRetry: _noop,
                ),
              ),
              Expanded(child: DlmLoadingState(label: 'Loading downloads')),
            ],
          ),
        ),
        SizedBox(height: gap),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DlmSkeleton(width: 180),
            SizedBox(width: 16),
            DlmSkeleton(width: 120, height: 20),
          ],
        ),
      ],
    );
  }
}

void _noop() {}

/// Every built-in glyph with its name.
class IconsSection extends StatelessWidget {
  /// Creates the section.
  const IconsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return Wrap(
      spacing: theme.metrics.spacing.lg,
      runSpacing: theme.metrics.spacing.md,
      children: [
        for (final name in DlmIconName.values)
          SizedBox(
            width: 84,
            child: Column(
              children: [
                DlmIcon(name, size: 24, color: theme.colors.textPrimary),
                SizedBox(height: theme.metrics.spacing.xs),
                Text(
                  name.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
