import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

String _resize(String column) => 'Resize $column';

const _rows = ['H:fruit', 'apple', 'pear', 'H:veg', 'kale'];

void main() {
  Future<List<Set<Object>>> pumpCards(WidgetTester tester) async {
    final selections = <Set<Object>>[];
    var selected = <Object>{};
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 240,
          height: 400,
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
                width: 900,
                cell: (_, r) => Text(r),
              ),
            ],
            itemCount: _rows.length,
            itemAt: (i) => _rows[i],
            rowId: (r) => r,
            rowSemanticLabel: (r) => r,
            isGroupHeader: (r) => r.startsWith('H:'),
            groupHeader: (_, r) => Text('GROUP ${r.substring(2)}'),
            rowExtent: 90,
            groupHeaderExtent: 30,
            rowBuilder: (_, r, states) => SizedBox(
              height: 90,
              child: Text('CARD $r${states.selected ? ' *' : ''}'),
            ),
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

  testWidgets('cards replace the columns: no header, no sideways scroll', (
    tester,
  ) async {
    await pumpCards(tester);
    expect(find.text('Name'), findsNothing, reason: 'no header');
    expect(find.text('CARD apple'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('headings are shorter than cards', (tester) async {
    await pumpCards(tester);
    final fruit = tester.getRect(find.text('GROUP fruit')).top;
    final apple = tester.getRect(find.text('CARD apple')).top;
    final pear = tester.getRect(find.text('CARD pear')).top;
    expect(apple - fruit, closeTo(30, 12));
    expect(pear - apple, closeTo(90, 1));
  });

  testWidgets('a card is selected by tapping and says so', (tester) async {
    final selections = await pumpCards(tester);
    await tester.tap(find.text('CARD pear'));
    await tester.pump();
    expect(selections.last, {'pear'});
    expect(find.text('CARD pear *'), findsOneWidget);
  });
}
