import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// Banners, toasts, tooltips, dialogs, sheets, popovers and context menus.
class OverlaysSection extends StatefulWidget {
  /// Creates the section; [toasts] is the page's toast controller.
  const OverlaysSection({required this.toasts, super.key});

  /// Where toasts are shown.
  final DlmToastController toasts;

  @override
  State<OverlaysSection> createState() => _OverlaysSectionState();
}

class _OverlaysSectionState extends State<OverlaysSection> {
  final DlmPopoverController _popover = DlmPopoverController();
  String _last = 'nothing yet';

  void _toast(DlmTone tone, String message) => widget.toasts.show(
    DlmToast(
      message: message,
      tone: tone,
      dismissLabel: 'Dismiss',
      actionLabel: tone == DlmTone.danger ? 'Retry' : null,
      onAction: tone == DlmTone.danger ? () {} : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final gap = DlmTheme.of(context).metrics.spacing.md;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tone in [
          DlmTone.info,
          DlmTone.success,
          DlmTone.warning,
          DlmTone.danger,
        ]) ...[
          SizedBox(
            width: 560,
            child: DlmBanner(
              tone: tone,
              title: '${tone.name[0].toUpperCase()}${tone.name.substring(1)}',
              message: 'This is a ${tone.name} message in a banner.',
              actionLabel: 'Details',
              onAction: () {},
              onDismiss: () {},
              dismissLabel: 'Dismiss',
            ),
          ),
          SizedBox(height: gap),
        ],
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            DlmButton(
              label: 'Info toast',
              onPressed: () => _toast(DlmTone.info, 'Link copied'),
            ),
            DlmButton(
              label: 'Success toast',
              onPressed: () => _toast(DlmTone.success, 'Download finished'),
            ),
            DlmButton(
              label: 'Error toast',
              onPressed: () =>
                  _toast(DlmTone.danger, 'The server refused the connection'),
            ),
            DlmTooltip(
              message: 'Pauses every active download',
              child: DlmButton(label: 'Hover for tooltip', onPressed: () {}),
            ),
            DlmPopover(
              controller: _popover,
              popoverBuilder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popover',
                    style: DlmTheme.of(context).typography.bodyStrong,
                  ),
                  SizedBox(height: gap),
                  const SizedBox(
                    width: 220,
                    child: DlmTextField(
                      placeholder: 'Anything',
                      semanticLabel: 'Anything',
                    ),
                  ),
                ],
              ),
              child: DlmButton(label: 'Popover', onPressed: _popover.toggle),
            ),
            DlmButton(
              label: 'Dialog',
              onPressed: () async {
                final yes = await showDlmConfirm(
                  context,
                  title: 'Delete 3 downloads?',
                  message: 'The files stay on disk.',
                  confirmLabel: 'Delete',
                  cancelLabel: 'Cancel',
                  destructive: true,
                );
                setState(() => _last = yes ? 'confirmed' : 'cancelled');
              },
            ),
            DlmButton(
              label: 'Sheet',
              onPressed: () => showDlmDialog<void>(
                context,
                semanticLabel: 'Add download',
                kind: DlmDialogKind.sheet,
                builder: (context) => DlmDialogContent(
                  title: 'Add download',
                  child: const DlmTextField(
                    placeholder: 'https://',
                    semanticLabel: 'Link',
                    autofocus: true,
                  ),
                  actions: [
                    DlmButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    DlmButton(
                      label: 'Add',
                      variant: DlmButtonVariant.primary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        Text('Last dialog: $_last'),
        SizedBox(height: gap),
        DlmContextMenuRegion(
          entries: () => [
            const DlmMenuHeader('Download'),
            DlmMenuItem(
              label: 'Pause',
              shortcut: '⌘P',
              onPressed: () => setState(() => _last = 'pause'),
            ),
            DlmMenuItem(
              label: 'Open folder',
              onPressed: () => setState(() => _last = 'open'),
            ),
            const DlmMenuSeparator(),
            DlmMenuItem(
              label: 'Delete',
              destructive: true,
              onPressed: () => setState(() => _last = 'delete'),
            ),
          ],
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: DlmTheme.of(context).colors.separator),
              borderRadius: BorderRadius.circular(
                DlmTheme.of(context).metrics.radii.container,
              ),
            ),
            child: const SizedBox(
              width: 360,
              height: 72,
              child: Center(child: Text('Right-click here for a context menu')),
            ),
          ),
        ),
      ],
    );
  }
}
