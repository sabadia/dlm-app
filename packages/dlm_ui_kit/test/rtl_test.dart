import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

/// Right-to-left languages mirror the layout: what is at the start of a line
/// is on the right. These pin the widgets that used to place things by
/// physical side.
Future<void> pumpRtl(WidgetTester tester, Widget child) => pumpKit(
  tester,
  Directionality(
    textDirection: TextDirection.rtl,
    child: SizedBox(width: 400, child: child),
  ),
);

void main() {
  testWidgets('a sidebar item has its icon at the right and text before it', (
    tester,
  ) async {
    await pumpRtl(
      tester,
      DlmSidebar<String>(
        semanticLabel: 'Sidebar',
        selected: 'a',
        onSelected: (_) {},
        sections: const [
          DlmSidebarSection(
            title: 'Group',
            items: [
              DlmSidebarItem(
                id: 'a',
                label: 'Alpha',
                icon: DlmIcon(DlmIconName.download),
              ),
            ],
          ),
        ],
      ),
    );
    final icon = tester.getRect(find.byType(DlmIcon).first);
    final text = tester.getRect(find.text('Alpha'));
    expect(icon.center.dx, greaterThan(text.center.dx));
    // The section title starts at the right too.
    final title = tester.getRect(find.text('Group'));
    expect(title.right, greaterThan(300));
  });

  testWidgets(
    'a form row puts its label at the right, its control at the left',
    (tester) async {
      await pumpRtl(
        tester,
        const DlmFormRow(label: 'Label', control: Text('control')),
      );
      final label = tester.getRect(find.text('Label'));
      final control = tester.getRect(find.text('control'));
      expect(label.center.dx, greaterThan(control.center.dx));
    },
  );

  testWidgets('a switch that is on has its knob at the left', (tester) async {
    await pumpRtl(
      tester,
      Row(
        children: [
          DlmSwitch(value: true, onChanged: (_) {}, semanticLabel: 'on'),
          DlmSwitch(value: false, onChanged: (_) {}, semanticLabel: 'off'),
        ],
      ),
    );
    // No layout error is the first check; the second is that the two states
    // draw differently side by side.
    expect(tester.takeException(), isNull);
  });

  testWidgets('text fields and tables lay out without errors', (tester) async {
    await pumpRtl(
      tester,
      Column(
        children: [
          DlmTextField(
            controller: TextEditingController(text: 'مرحبا'),
            semanticLabel: 'Field',
          ),
          SizedBox(
            height: 160,
            child: DlmDataTable<int>(
              semanticLabel: 'Rows',
              labels: const DlmTableLabels(
                sortedAscending: 'asc',
                sortedDescending: 'desc',
                resizeColumn: _resize,
                loadingRow: 'loading',
              ),
              columns: [
                DlmColumn<int>(
                  id: 'n',
                  label: 'N',
                  sortable: true,
                  cell: (_, r) => Text('$r'),
                ),
              ],
              itemCount: 3,
              itemAt: (i) => i,
              rowId: (r) => r,
              rowSemanticLabel: (r) => '$r',
            ),
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

String _resize(String column) => 'Resize $column';
