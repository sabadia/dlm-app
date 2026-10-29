import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// Every text input.
class InputsSection extends StatefulWidget {
  /// Creates the section.
  const InputsSection({super.key});

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  int? _size = 1048576;
  num? _number = 8;

  static final _units = {'k': 1024, 'm': 1048576, 'g': 1073741824};

  int? _parseSize(String text) {
    final m = RegExp(
      r'^(\d+(?:\.\d+)?)\s*([kmg])?b?$',
      caseSensitive: false,
    ).firstMatch(text);
    if (m == null) return null;
    final n = double.parse(m.group(1)!);
    final unit = m.group(2)?.toLowerCase();
    return (n * (unit == null ? 1 : _units[unit]!)).round();
  }

  String _formatSize(int bytes) => bytes >= 1048576
      ? '${(bytes / 1048576).toStringAsFixed(bytes % 1048576 == 0 ? 0 : 1)} MB'
      : '${(bytes / 1024).toStringAsFixed(0)} KB';

  @override
  Widget build(BuildContext context) {
    final gap = DlmTheme.of(context).metrics.spacing.md;
    Widget box(Widget child) => SizedBox(width: 320, child: child);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            box(const DlmTextField(placeholder: 'Text', semanticLabel: 'Text')),
            box(
              const DlmTextField(
                placeholder: 'Disabled',
                semanticLabel: 'Disabled',
                enabled: false,
              ),
            ),
            box(
              const DlmTextField(
                placeholder: 'With error',
                semanticLabel: 'Error',
                errorText: 'This link is not valid',
              ),
            ),
            box(
              DlmSearchField(
                onChanged: (_) {},
                clearLabel: 'Clear',
                placeholder: 'Search',
                semanticLabel: 'Search',
              ),
            ),
            box(
              const DlmPasswordField(
                showLabel: 'Show password',
                hideLabel: 'Hide password',
                placeholder: 'Password',
                semanticLabel: 'Password',
              ),
            ),
            box(
              DlmParsedField<int>(
                value: _size,
                parse: _parseSize,
                format: _formatSize,
                invalidText: 'Enter a size such as 10M',
                semanticLabel: 'Speed limit',
                suffix: const Text('per second'),
                onChanged: (v) => setState(() => _size = v),
              ),
            ),
            SizedBox(
              width: 140,
              child: DlmNumberField(
                value: _number,
                min: 1,
                max: 16,
                invalidText: 'Between 1 and 16',
                semanticLabel: 'Connections',
                onChanged: (v) => setState(() => _number = v),
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        const SizedBox(
          width: 660,
          child: DlmTextField(
            maxLines: null,
            minLines: 3,
            placeholder: 'One link per line',
            semanticLabel: 'Links',
          ),
        ),
      ],
    );
  }
}
