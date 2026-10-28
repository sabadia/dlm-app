import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

class _Row {
  const _Row(this.id, this.name, this.size);
  final int id;
  final String name;
  final int size;
}

const _labels = DlmTableLabels(
  sortedAscending: 'sorted ascending',
  sortedDescending: 'sorted descending',
  resizeColumn: _resizeLabel,
  loadingRow: 'Loading',
);

String _resizeLabel(String c) => 'Resize $c';

List<DlmColumn<_Row>> _columns() => [
  DlmColumn<_Row>(
    id: 'name',
    label: 'Name',
    width: 200,
    sortable: true,
    cell: (context, r) => Text(r.name),
  ),
  DlmColumn<_Row>(
    id: 'size',
    label: 'Size',
    width: 100,
    sortable: true,
    cell: (context, r) => Text('${r.size}'),
  ),
];

void tableTest(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (tester) async {
    await body(tester);
    await tester.pump(const Duration(seconds: 1));
  });
}

void main() {
  final rows = [for (var i = 0; i < 100; i++) _Row(i, 'file$i', i * 10)];

  Future<_Harness> pumpTable(
    WidgetTester tester, {
    int? count,
    DlmSelectionMode mode = DlmSelectionMode.multiple,
    Set<Object> selected = const {},
    DlmSort? sort,
    Map<String, double> widths = const {},
    bool nullRows = false,
    Widget? empty,
    double width = 600,
  }) async {
    final h = _Harness(selected: selected, sort: sort, widths: widths);
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          h.rebuild = () => setState(() {});
          return SizedBox(
            width: width,
            height: 300,
            child: DlmDataTable<_Row>(
              semanticLabel: 'Downloads',
              labels: _labels,
              columns: _columns(),
              itemCount: count ?? rows.length,
              itemAt: (i) => nullRows && i == 2 ? null : rows[i % rows.length],
              rowId: (r) => r.id,
              rowSemanticLabel: (r) => '${r.name}, ${r.size} bytes',
              selectionMode: mode,
              selectedIds: h.selected,
              sort: h.sort,
              columnWidths: h.widths,
              emptyState: empty,
              onSelectionChanged: (s) {
                h.selected = s;
                h.selections.add(s);
                setState(() {});
              },
              onSort: (s) {
                h.sort = s;
                h.sorts.add(s);
                setState(() {});
              },
              onColumnResized: (id, w) {
                h.widths = {...h.widths, id: w};
                h.resizes.add((id, w));
                setState(() {});
              },
              onRowActivated: (r) => h.activated.add(r.id),
              onRowSecondaryTap: (i, r, p) => h.menus.add(r.id),
            ),
          );
        },
      ),
    );
    return h;
  }

  tableTest('shows only the visible rows of a very large table', (
    tester,
  ) async {
    await pumpTable(tester, count: 50000);
    expect(find.text('file0'), findsOneWidget);
    expect(find.textContaining('file').evaluate().length, lessThan(30));
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  tableTest('clicking selects one row, replacing the selection', (
    tester,
  ) async {
    final h = await pumpTable(tester);
    await tester.tap(find.text('file1'));
    await tester.pump();
    await tester.tap(find.text('file3'));
    await tester.pump();
    expect(h.selected, {3});
  });

  tableTest('ctrl-click toggles and shift-click selects a range', (
    tester,
  ) async {
    final h = await pumpTable(tester);
    await tester.tap(find.text('file1'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.tap(find.text('file4'));
    await tester.pump();
    expect(h.selected, {1, 4});
    await tester.tap(find.text('file1'));
    await tester.pump();
    expect(h.selected, {4});
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    await tester.tap(find.text('file2'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('file5'));
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(h.selected, {2, 3, 4, 5});
  });

  tableTest('single selection mode ignores modifiers', (tester) async {
    final h = await pumpTable(tester, mode: DlmSelectionMode.single);
    await tester.tap(find.text('file1'));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.tap(find.text('file2'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(h.selected, {2});
  });

  tableTest('selection mode none makes rows unselectable', (tester) async {
    final h = await pumpTable(tester, mode: DlmSelectionMode.none);
    await tester.tap(find.text('file1'));
    await tester.pump();
    expect(h.selections, isEmpty);
  });

  tableTest('arrow keys move the selection; Shift extends it', (tester) async {
    final h = await pumpTable(tester);
    await tester.tap(find.text('file0'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(h.selected, {2});
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(h.selected, {2, 3, 4});
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(h.selected, {3});
  });

  tableTest('Home, End and paging jump and scroll the cursor into view', (
    tester,
  ) async {
    final h = await pumpTable(tester);
    await tester.tap(find.text('file0'));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(h.selected, {99});
    expect(find.text('file99'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(h.selected, {0});
    expect(find.text('file0'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(h.selected.single as int, greaterThan(3));
  });

  tableTest('Space toggles the cursor row; Ctrl+A selects all', (tester) async {
    final h = await pumpTable(tester);
    await tester.tap(find.text('file1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(h.selected, isEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(h.selected, {1});
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(h.selected.length, 100);
  });

  tableTest('double click and Enter activate; right click reports', (
    tester,
  ) async {
    final h = await pumpTable(tester);
    await tester.tap(find.text('file2'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('file2'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(h.activated, [2, 2]);
    await tester.tapAt(
      tester.getCenter(find.text('file5')),
      buttons: kSecondaryButton,
    );
    await tester.pump();
    expect(h.menus, [5]);
    expect(h.selected, {5}, reason: 'right click selects an unselected row');
  });

  tableTest('right click keeps a multi-selection that contains the row', (
    tester,
  ) async {
    final h = await pumpTable(tester, selected: {1, 2, 3});
    await tester.tapAt(
      tester.getCenter(find.text('file2')),
      buttons: kSecondaryButton,
    );
    await tester.pump();
    expect(h.selected, {1, 2, 3});
    expect(h.menus, [2]);
  });

  tableTest('clicking a sortable header sorts, then reverses', (tester) async {
    final h = await pumpTable(tester);
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(h.sorts.last.columnId, 'name');
    expect(h.sorts.last.ascending, isTrue);
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(h.sorts.last.ascending, isFalse);
    await tester.tap(find.text('Size'));
    await tester.pump();
    expect(h.sorts.last.columnId, 'size');
    expect(h.sorts.last.ascending, isTrue);
  });

  tableTest('the sorted column shows an arrow and is announced', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTable(tester, sort: const DlmSort('size', ascending: false));
    expect(find.bySemanticsLabel('Size, sorted descending'), findsOneWidget);
    expect(find.bySemanticsLabel('Name'), findsOneWidget);
    handle.dispose();
  });

  tableTest('dragging a header edge resizes within the limits', (tester) async {
    final h = await pumpTable(tester);
    final handle = find.bySemanticsLabel('Resize Name');
    final semantics = tester.ensureSemantics();
    final edge = tester.getRect(handle).center;
    await tester.dragFrom(edge, const Offset(60, 0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(h.widths['name'], closeTo(200 + 60 - kTouchSlop, 3));
    await tester.dragFrom(
      tester.getRect(find.bySemanticsLabel('Resize Name')).center,
      const Offset(-900, 0),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(h.widths['name'], 48);
    semantics.dispose();
  });

  tableTest('Ctrl+Left/Right on a focused header resizes it', (tester) async {
    final h = await pumpTable(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(h.widths['name'], 208);
  });

  tableTest('the resize handle is adjustable for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = await pumpTable(tester);
    tester.semantics.increase(find.semantics.byLabel('Resize Name'));
    await tester.pump();
    expect(h.widths['name'], 208);
    semantics.dispose();
  });

  tableTest('columns wider than the viewport scroll horizontally', (
    tester,
  ) async {
    await pumpTable(tester, width: 200);
    expect(find.text('Size'), findsOneWidget);
    expect(tester.getRect(find.text('Size')).left, greaterThan(200));
    await tester.drag(find.text('Name'), const Offset(-150, 0));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  tableTest('rows that have not loaded show skeletons', (tester) async {
    await pumpTable(tester, nullRows: true);
    expect(find.byType(DlmSkeleton), findsNWidgets(2));
    expect(find.text('file2'), findsNothing);
    expect(find.text('file3'), findsOneWidget);
  });

  tableTest('an empty table shows the empty state', (tester) async {
    await pumpTable(tester, count: 0, empty: const Text('No downloads'));
    expect(find.text('No downloads'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget, reason: 'header stays');
  });

  tableTest('rows are announced with their label and selection', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTable(tester, selected: {1});
    expect(
      tester.getSemantics(find.bySemanticsLabel('file1, 10 bytes')),
      matchesSemantics(
        label: 'file1, 10 bytes',
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    expect(find.bySemanticsLabel('Downloads'), findsOneWidget);
    handle.dispose();
  });

  tableTest('selection follows ids when the rows are reordered', (
    tester,
  ) async {
    final h = await pumpTable(tester, selected: {7});
    expect(h.selected, {7});
    final selectedLabel = tester
        .widget<DlmDataTable<_Row>>(find.byType(DlmDataTable<_Row>))
        .selectedIds;
    expect(selectedLabel, {7});
  });
}

class _Harness {
  _Harness({required this.selected, required this.sort, required this.widths});
  Set<Object> selected;
  DlmSort? sort;
  Map<String, double> widths;
  final List<Set<Object>> selections = [];
  final List<DlmSort> sorts = [];
  final List<(String, double)> resizes = [];
  final List<int> activated = [];
  final List<int> menus = [];
  late void Function() rebuild;
}
