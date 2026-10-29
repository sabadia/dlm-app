import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// Buttons in every variant, size and state.
class ActionsSection extends StatelessWidget {
  /// Creates the section.
  const ActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    void noop() {}
    final gap = DlmTheme.of(context).metrics.spacing.md;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            DlmButton(
              label: 'Primary',
              variant: DlmButtonVariant.primary,
              onPressed: noop,
            ),
            DlmButton(label: 'Secondary', onPressed: noop),
            DlmButton(
              label: 'Destructive',
              variant: DlmButtonVariant.destructive,
              onPressed: noop,
            ),
            DlmButton(
              label: 'Plain',
              variant: DlmButtonVariant.plain,
              onPressed: noop,
            ),
            const DlmButton(label: 'Disabled', onPressed: null),
            const DlmButton(
              label: 'Disabled',
              variant: DlmButtonVariant.primary,
              onPressed: null,
            ),
          ],
        ),
        SizedBox(height: gap),
        Wrap(
          spacing: gap,
          runSpacing: gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DlmButton(
              label: 'Small',
              size: DlmControlSize.small,
              onPressed: noop,
            ),
            DlmButton(label: 'Regular', onPressed: noop),
            DlmButton(
              label: 'Large',
              size: DlmControlSize.large,
              onPressed: noop,
            ),
            DlmButton(
              label: 'With icon',
              icon: const DlmIcon(DlmIconName.plus),
              onPressed: noop,
            ),
            DlmIconButton(
              icon: const DlmIcon(DlmIconName.search),
              semanticLabel: 'Search',
              onPressed: noop,
            ),
            DlmSplitButton(
              label: 'Add',
              menuLabel: 'More options',
              onPressed: noop,
              entries: [
                DlmMenuItem(label: 'Add paused', onPressed: noop),
                DlmMenuItem(label: 'Add to queue…', onPressed: noop),
              ],
            ),
            DlmMenuButton(
              label: 'Menu',
              entries: [
                DlmMenuItem(label: 'Open', shortcut: '⌘O', onPressed: noop),
                DlmMenuItem(label: 'Rename', onPressed: noop),
                const DlmMenuItem(label: 'Locked', onPressed: null),
                const DlmMenuSeparator(),
                DlmMenuItem(
                  label: 'Delete',
                  destructive: true,
                  onPressed: noop,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Switch, checkbox, radio, segmented, tabs, dropdown, combo box, slider.
class ChoiceSection extends StatefulWidget {
  /// Creates the section.
  const ChoiceSection({super.key});

  @override
  State<ChoiceSection> createState() => _ChoiceSectionState();
}

class _ChoiceSectionState extends State<ChoiceSection> {
  bool _switch = true;
  DlmCheckState _check = DlmCheckState.mixed;
  String _radio = 'a';
  String _segment = 'all';
  String _tab = 'overview';
  String? _dropdown = 'video';
  double _slider = 0.4;

  @override
  Widget build(BuildContext context) {
    final gap = DlmTheme.of(context).metrics.spacing.lg;
    const choices = [
      DlmChoice(value: 'video', label: 'Video'),
      DlmChoice(value: 'audio', label: 'Audio'),
      DlmChoice(value: 'archive', label: 'Archive'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DlmSwitch(
              value: _switch,
              label: 'Switch',
              onChanged: (v) => setState(() => _switch = v),
            ),
            const DlmSwitch(value: false, label: 'Disabled', onChanged: null),
            DlmCheckbox(
              value: _check,
              label: 'Checkbox',
              onChanged: (v) => setState(() => _check = v),
            ),
            DlmCheckbox(
              value: DlmCheckState.checked,
              label: 'Checked',
              onChanged: (_) {},
            ),
            const DlmCheckbox(
              value: DlmCheckState.unchecked,
              label: 'Disabled',
              onChanged: null,
            ),
            for (final v in ['a', 'b'])
              DlmRadio<String>(
                value: v,
                groupValue: _radio,
                label: 'Radio $v',
                onChanged: (x) => setState(() => _radio = x),
              ),
          ],
        ),
        SizedBox(height: gap),
        DlmSegmented<String>(
          options: const [
            DlmOption(value: 'all', label: 'All'),
            DlmOption(value: 'active', label: 'Active'),
            DlmOption(value: 'done', label: 'Completed'),
          ],
          value: _segment,
          onChanged: (v) => setState(() => _segment = v),
        ),
        SizedBox(height: gap),
        DlmTabBar<String>(
          tabs: const [
            DlmOption(value: 'overview', label: 'Overview'),
            DlmOption(value: 'files', label: 'Files'),
            DlmOption(value: 'speed', label: 'Speed'),
          ],
          value: _tab,
          onChanged: (v) => setState(() => _tab = v),
        ),
        SizedBox(height: gap),
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: 200,
              child: DlmDropdown<String>(
                choices: choices,
                value: _dropdown,
                semanticLabel: 'Category',
                onChanged: (v) => setState(() => _dropdown = v),
              ),
            ),
            SizedBox(
              width: 220,
              child: DlmComboBox<String>(
                choices: choices,
                semanticLabel: 'Category',
                placeholder: 'Type a category',
                onSelected: (_) {},
              ),
            ),
            SizedBox(
              width: 200,
              child: DlmSlider(
                value: _slider,
                semanticLabel: 'Connections',
                divisions: 10,
                onChanged: (v) => setState(() => _slider = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
