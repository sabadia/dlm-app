import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// A miniature window: toolbar, sidebar, content and inspector.
class StructureSection extends StatefulWidget {
  /// Creates the section.
  const StructureSection({super.key});

  @override
  State<StructureSection> createState() => _StructureSectionState();
}

class _StructureSectionState extends State<StructureSection> {
  String _selected = 'all';
  double _inspector = 200;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.separator),
        borderRadius: BorderRadius.circular(theme.metrics.radii.container),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.metrics.radii.container),
        child: SizedBox(
          height: 340,
          child: Row(
            children: [
              SizedBox(
                width: theme.metrics.sidebarWidth.min,
                child: DlmSidebar<String>(
                  semanticLabel: 'Navigation',
                  selected: _selected,
                  onSelected: (v) => setState(() => _selected = v),
                  header: Padding(
                    padding: EdgeInsets.all(theme.metrics.spacing.md),
                    child: DlmSearchField(
                      onChanged: (_) {},
                      clearLabel: 'Clear',
                      placeholder: 'Search',
                    ),
                  ),
                  sections: const [
                    DlmSidebarSection(
                      items: [
                        DlmSidebarItem(
                          id: 'all',
                          label: 'All Downloads',
                          icon: DlmIcon(DlmIconName.chevronDown),
                          count: 128,
                        ),
                        DlmSidebarItem(
                          id: 'active',
                          label: 'Active',
                          icon: DlmIcon(DlmIconName.chevronUp),
                          count: 3,
                        ),
                        DlmSidebarItem(
                          id: 'done',
                          label: 'Completed',
                          icon: DlmIcon(DlmIconName.check),
                        ),
                        DlmSidebarItem(
                          id: 'failed',
                          label: 'Failed',
                          icon: DlmIcon(DlmIconName.error),
                          count: 1,
                        ),
                      ],
                    ),
                    DlmSidebarSection(
                      title: 'Queues',
                      items: [
                        DlmSidebarItem(
                          id: 'night',
                          label: 'Overnight',
                          icon: DlmIcon(DlmIconName.more),
                        ),
                      ],
                    ),
                  ],
                  footer: Padding(
                    padding: EdgeInsets.all(theme.metrics.spacing.md),
                    child: const DlmBadge(
                      label: 'Connected',
                      tone: DlmTone.success,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: theme.colors.content,
                  child: Column(
                    children: [
                      DlmToolbar(
                        title: 'All Downloads',
                        semanticLabel: 'Toolbar',
                        leading: [
                          DlmIconButton(
                            icon: const DlmIcon(DlmIconName.chevronLeft),
                            semanticLabel: 'Back',
                            onPressed: () {},
                          ),
                        ],
                        actions: [
                          DlmButton(
                            label: 'Add',
                            icon: const DlmIcon(DlmIconName.plus),
                            variant: DlmButtonVariant.primary,
                            onPressed: () {},
                          ),
                          DlmIconButton(
                            icon: const DlmIcon(DlmIconName.more),
                            semanticLabel: 'More',
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Expanded(
                        child: DlmSplitView(
                          primaryAtEnd: true,
                          primarySize: _inspector,
                          minPrimary: 140,
                          minSecondary: 160,
                          dividerLabel: 'Resize inspector',
                          onResized: (v) => setState(() => _inspector = v),
                          secondary: const DlmEmptyState(
                            title: 'Select a download',
                          ),
                          primary: Padding(
                            padding: EdgeInsets.all(theme.metrics.spacing.md),
                            child: Text(
                              'Inspector',
                              style: theme.typography.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A settings-style group of form rows.
class FormSection extends StatefulWidget {
  /// Creates the section.
  const FormSection({super.key});

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  bool _auto = true;
  int _connections = 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 620,
      child: DlmFormGroup(
        title: 'Speed',
        footer: 'Applies to new downloads; running ones keep their settings.',
        children: [
          DlmFormRow(
            label: 'Connections per download',
            description:
                'More connections are faster but heavier on the server.',
            control: SizedBox(
              width: 100,
              child: DlmNumberField(
                value: _connections,
                min: 1,
                max: 16,
                invalidText: 'Between 1 and 16',
                semanticLabel: 'Connections per download',
                onChanged: (v) =>
                    setState(() => _connections = v?.toInt() ?? 8),
              ),
            ),
          ),
          DlmFormRow(
            label: 'Sort into category folders',
            control: DlmSwitch(
              value: _auto,
              semanticLabel: 'Sort',
              onChanged: (v) => setState(() => _auto = v),
            ),
          ),
          DlmFormRow(
            label: 'Default folder',
            description: '~/Downloads',
            control: DlmButton(label: 'Choose…', onPressed: () {}),
          ),
        ],
      ),
    );
  }
}
