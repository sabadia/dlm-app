import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

String _resize(String column) => 'Resize $column';

void main() {
  testWidgets('a drag dropped on a row reports that row, a refused one not', (
    tester,
  ) async {
    final drops = <(int, String, Object)>[];
    await pumpKit(
      tester,
      Column(
        children: [
          const Draggable<Object>(
            data: 'item',
            feedback: SizedBox(width: 10, height: 10),
            child: SizedBox(width: 60, height: 30, child: Text('HANDLE')),
          ),
          SizedBox(
            width: 400,
            height: 200,
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
              itemCount: 3,
              itemAt: (i) => ['a', 'b', 'c'][i],
              rowId: (r) => r,
              rowSemanticLabel: (r) => r,
              onSelectionChanged: (_) {},
              acceptRowDrop: (i, row, data) => row != 'c',
              onRowDrop: (i, row, data) => drops.add((i, row, data)),
            ),
          ),
        ],
      ),
    );

    Future<void> dragTo(String row) async {
      final g = await tester.startGesture(
        tester.getCenter(find.text('HANDLE')),
      );
      await g.moveTo(tester.getCenter(find.text(row)));
      await tester.pump();
      await g.up();
      await tester.pump();
    }

    await dragTo('c');
    expect(drops, isEmpty);
    await dragTo('b');
    expect(drops, [(1, 'b', 'item')]);
  });
}
