import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

String _resize(String column) => 'Resize $column';

const _rows = ['H:fruit', 'apple', 'pear', 'H:veg', 'kale'];

void main() {
  Future<List<Set<Object>>> pumpGrouped(WidgetTester tester) async {
    final selections = <Set<Object>>[];
    var selected = <Object>{};
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 400,
          height: 300,
          child: DlmDataTable<String>(
            semanticLabel: 'Rows',
            labels: const DlmTableLabels(
              sortedAscending: 'asc',
              sortedDescending: 'desc',
              resizeColumn: _resize,
              loadingRow: 'loading',
            ),
            columns: [
              DlmColumn<String>(
                id: 'name',
                label: 'Name',
                cell: (_, r) => Text(r),
              ),
            ],
            itemCount: _rows.length,
            itemAt: (i) => _rows[i],
            rowId: (r) => r,
            rowSemanticLabel: (r) => r,
            isGroupHeader: (r) => r.startsWith('H:'),
            groupHeader: (_, r) => Text('GROUP ${r.substring(2)}'),
            selectedIds: selected,
            onSelectionChanged: (s) => setState(() {
              selected = s;
              selections.add(s);
            }),
          ),
        ),
      ),
    );
    return selections;
  }

  testWidgets('a heading is drawn by the group header, not as a row', (
    tester,
  ) async {
    await pumpGrouped(tester);
    expect(find.text('GROUP fruit'), findsOneWidget);
    expect(find.text('GROUP veg'), findsOneWidget);
    expect(find.text('H:fruit'), findsNothing);
    expect(find.text('apple'), findsOneWidget);
  });

  testWidgets('a heading cannot be selected', (tester) async {
    final selections = await pumpGrouped(tester);
    await tester.tap(find.text('GROUP fruit'));
    await tester.pump();
    expect(selections, isEmpty);
    await tester.tap(find.text('apple'));
    await tester.pump();
    expect(selections.last, {'apple'});
  });

  testWidgets('select all leaves the headings out', (tester) async {
    final selections = await pumpGrouped(tester);
    await tester.tap(find.text('apple'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(selections.last, {'apple', 'pear', 'kale'});
  });

  testWidgets('the arrow keys pass over a heading', (tester) async {
    final selections = await pumpGrouped(tester);
    await tester.tap(find.text('pear'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(selections.last, {'kale'}, reason: 'H:veg is skipped');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(selections.last, {'pear'});
  });
}
