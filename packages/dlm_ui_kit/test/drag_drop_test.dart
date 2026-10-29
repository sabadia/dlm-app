import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _labels = DlmTableLabels(
  sortedAscending: 'ascending',
  sortedDescending: 'descending',
  resizeColumn: _resize,
  loadingRow: 'loading',
);

String _resize(String column) => 'Resize $column';

void main() {
  Future<List<Object>> dropOnto(
    WidgetTester tester, {
    required Object? Function(int index, String row)? dragData,
    required bool Function(Object data) onDrop,
  }) async {
    final dropped = <Object>[];
    await pumpKit(
      tester,
      Row(
        children: [
          SizedBox(
            width: 220,
            child: DlmSidebar<String>(
              semanticLabel: 'Navigation',
              selected: 'all',
              onSelected: (_) {},
              sections: [
                DlmSidebarSection(
                  items: [
                    const DlmSidebarItem(id: 'all', label: 'All'),
                    DlmSidebarItem(
                      id: 'night',
                      label: 'Night',
                      onDrop: (d) {
                        dropped.add(d);
                        return onDrop(d);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: DlmDataTable<String>(
              semanticLabel: 'Rows',
              labels: _labels,
              columns: [
                DlmColumn<String>(
                  id: 'name',
                  label: 'Name',
                  cell: (_, r) => Text(r),
                ),
              ],
              itemCount: 2,
              itemAt: (i) => ['one', 'two'][i],
              rowId: (r) => r,
              rowSemanticLabel: (r) => r,
              dragData: dragData,
              dragFeedback: (_, data) => Text('dragging $data'),
            ),
          ),
        ],
      ),
    );
    final from = tester.getCenter(find.text('one'));
    final to = tester.getCenter(find.text('Night'));
    final gesture = await tester.startGesture(from);
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('dragging one'), findsOneWidget);
    await gesture.moveTo(to);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
    return dropped;
  }

  testWidgets('a row dragged onto a sidebar item is dropped there', (
    tester,
  ) async {
    final dropped = await dropOnto(
      tester,
      dragData: (_, row) => row,
      onDrop: (_) => true,
    );
    expect(dropped, ['one']);
  });

  testWidgets('a row without drag data cannot be dragged', (tester) async {
    final dropped = <Object>[];
    await pumpKit(
      tester,
      DlmDataTable<String>(
        semanticLabel: 'Rows',
        labels: _labels,
        columns: [
          DlmColumn<String>(id: 'name', label: 'Name', cell: (_, r) => Text(r)),
        ],
        itemCount: 1,
        itemAt: (_) => 'one',
        rowId: (r) => r,
        rowSemanticLabel: (r) => r,
        dragData: (_, _) => null,
        dragFeedback: (_, d) => Text('dragging $d'),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('one')),
    );
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('dragging'), findsNothing);
    await gesture.up();
    expect(dropped, isEmpty);
  });
}
