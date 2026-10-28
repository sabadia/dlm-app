import 'package:dlm_gallery/gallery_app.dart';
import 'package:dlm_gallery/sections/sections.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

const _accents = <(String, Color?)>[
  ('Skin', null),
  ('Blue', Color(0xFF007AFF)),
  ('Purple', Color(0xFFAF52DE)),
  ('Green', Color(0xFF30D158)),
  ('Orange', Color(0xFFFF9F0A)),
  ('Yellow', Color(0xFFFFD60A)),
];

/// The control panel beside the scrolling list of component sections.
class GalleryPage extends StatefulWidget {
  /// Creates the page.
  const GalleryPage({
    required this.skins,
    required this.settings,
    required this.chrome,
    required this.onChanged,
    super.key,
  });

  /// The skins to choose from.
  final List<DlmSkin> skins;

  /// The current settings.
  final GallerySettings settings;

  /// Where the sidebar's backdrop region is reported.
  final WindowChrome chrome;

  /// Called with changed settings.
  final ValueChanged<GallerySettings> onChanged;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final DlmToastController _toasts = DlmToastController();
  double _panel = 280;

  @override
  void dispose() {
    _toasts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return ColoredBox(
      color: theme.windowBackground,
      child: DlmToastHost(
        controller: _toasts,
        child: DlmSplitView(
          primarySize: _panel,
          minPrimary: 240,
          minSecondary: 480,
          initialSize: 280,
          dividerLabel: 'Resize control panel',
          onResized: (v) => setState(() => _panel = v),
          primary: BackdropRegion(
            chrome: widget.chrome,
            child: theme.components.sidebarSurface(
              context,
              child: _controls(context, theme),
            ),
          ),
          secondary: ColoredBox(
            color: theme.colors.content,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                theme.metrics.spacing.xl,
                theme.metrics.spacing.xl + theme.titleBarInset,
                theme.metrics.spacing.xl,
                theme.metrics.spacing.xl,
              ),
              children: [
                for (final (title, body) in gallerySections(context, _toasts))
                  if (widget.settings.section == null ||
                      widget.settings.section == title) ...[
                    Semantics(
                      header: true,
                      child: Text(title, style: theme.typography.title),
                    ),
                    SizedBox(height: theme.metrics.spacing.md),
                    body,
                    SizedBox(height: theme.metrics.spacing.xxl),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls(BuildContext context, DlmThemeData theme) {
    final s = widget.settings;
    final gap = SizedBox(height: theme.metrics.spacing.md);
    void set(GallerySettings next) => widget.onChanged(next);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        theme.metrics.spacing.lg,
        theme.metrics.spacing.lg + theme.titleBarInset,
        theme.metrics.spacing.lg,
        theme.metrics.spacing.lg,
      ),
      children: [
        Text('dlm UI kit', style: theme.typography.headline),
        gap,
        DlmFormGroup(
          title: 'Look',
          children: [
            DlmFormRow(
              label: 'Skin',
              stackBelow: 1000,
              control: SizedBox(
                width: 140,
                child: DlmDropdown<int>(
                  semanticLabel: 'Skin',
                  value: s.skinIndex,
                  choices: [
                    for (var i = 0; i < widget.skins.length; i++)
                      DlmChoice(value: i, label: widget.skins[i].id),
                  ],
                  onChanged: (v) => set(s.copyWith(skinIndex: v)),
                ),
              ),
            ),
            DlmFormRow(
              label: 'Dark',
              control: DlmSwitch(
                value: s.dark,
                semanticLabel: 'Dark',
                onChanged: (v) => set(s.copyWith(dark: v)),
              ),
            ),
            DlmFormRow(
              label: 'High contrast',
              control: DlmSwitch(
                value: s.highContrast,
                semanticLabel: 'High contrast',
                onChanged: (v) => set(s.copyWith(highContrast: v)),
              ),
            ),
            DlmFormRow(
              label: 'Reduce motion',
              control: DlmSwitch(
                value: s.reduceMotion,
                semanticLabel: 'Reduce motion',
                onChanged: (v) => set(s.copyWith(reduceMotion: v)),
              ),
            ),
            DlmFormRow(
              label: 'Reduce transparency',
              control: DlmSwitch(
                value: s.reduceTransparency,
                semanticLabel: 'Reduce transparency',
                onChanged: (v) => set(s.copyWith(reduceTransparency: v)),
              ),
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: 'Show',
          children: [
            DlmFormRow(
              label: 'Section',
              stackBelow: 1000,
              control: SizedBox(
                width: 140,
                child: DlmDropdown<String?>(
                  semanticLabel: 'Section',
                  value: s.section,
                  choices: [
                    const DlmChoice(value: null, label: 'All'),
                    for (final t in gallerySectionTitles)
                      DlmChoice(value: t, label: t),
                  ],
                  onChanged: (v) => set(
                    v == null
                        ? s.copyWith(clearSection: true)
                        : s.copyWith(section: v),
                  ),
                ),
              ),
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: 'Size',
          children: [
            DlmFormRow(
              label: 'Density',
              stackBelow: 1000,
              control: DlmSegmented<DlmDensity>(
                options: const [
                  DlmOption(value: DlmDensity.compact, label: 'S'),
                  DlmOption(value: DlmDensity.regular, label: 'M'),
                  DlmOption(value: DlmDensity.comfortable, label: 'L'),
                ],
                value: s.density,
                onChanged: (v) => set(s.copyWith(density: v)),
              ),
            ),
            DlmFormRow(
              label: 'Text ${(s.textScale * 100).round()}%',
              stackBelow: 1000,
              control: SizedBox(
                width: 120,
                child: DlmSlider(
                  value: s.textScale,
                  min: 0.8,
                  max: 2,
                  semanticLabel: 'Text scale',
                  formatValue: (v) => '${(v * 100).round()}%',
                  onChanged: (v) => set(s.copyWith(textScale: v)),
                ),
              ),
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: 'Accent',
          children: [
            Padding(
              padding: EdgeInsets.all(theme.metrics.spacing.md),
              child: Wrap(
                spacing: theme.metrics.spacing.sm,
                runSpacing: theme.metrics.spacing.sm,
                children: [
                  for (final (name, color) in _accents)
                    DlmChip(
                      label: name,
                      selected: s.accent == color,
                      onSelected: (_) => set(
                        color == null
                            ? s.copyWith(clearAccent: true)
                            : s.copyWith(accent: color),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
