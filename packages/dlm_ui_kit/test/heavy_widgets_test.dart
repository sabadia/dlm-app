import 'dart:ui' show CheckedState;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';
import 'support/test_skin.dart';

const _tree = [
  DlmTreeNode(
    id: 'dir',
    label: 'dir',
    children: [
      DlmTreeNode(id: 'dir/a', label: 'a.txt'),
      DlmTreeNode(
        id: 'dir/sub',
        label: 'sub',
        children: [
          DlmTreeNode(id: 'dir/sub/b', label: 'b.txt'),
          DlmTreeNode(id: 'dir/sub/c', label: 'c.txt'),
        ],
      ),
    ],
  ),
  DlmTreeNode(id: 'readme', label: 'readme.md'),
];

class _TreeHarness {
  Set<Object> expanded = {};
  Set<Object> checked = {};
  final List<Object> activated = [];
}

void main() {
  Future<_TreeHarness> pumpTree(
    WidgetTester tester, {
    Set<Object>? expanded,
    Set<Object>? checked,
    bool checkable = true,
    List<DlmTreeNode> roots = _tree,
  }) async {
    final h = _TreeHarness()
      ..expanded = expanded ?? {}
      ..checked = checked ?? {};
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 400,
          height: 300,
          child: DlmTree(
            semanticLabel: 'Files',
            roots: roots,
            expandedIds: h.expanded,
            checkedIds: h.checked,
            onExpandedChanged: (s) => setState(() => h.expanded = s),
            onCheckedChanged: checkable
                ? (s) => setState(() => h.checked = s)
                : null,
            onActivated: (n) => h.activated.add(n.id),
          ),
        ),
      ),
    );
    return h;
  }

  group('DlmTree', () {
    testWidgets('shows collapsed roots and expands on the chevron', (
      tester,
    ) async {
      final h = await pumpTree(tester);
      expect(find.text('dir'), findsOneWidget);
      expect(find.text('a.txt'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('dlm-tree-toggle-dir')));
      await tester.pump();
      expect(h.expanded, {'dir'});
      expect(find.text('a.txt'), findsOneWidget);
    });

    testWidgets('checking a folder checks every leaf below it', (tester) async {
      final h = await pumpTree(tester, expanded: {'dir', 'dir/sub'});
      await tester.tapAt(_checkboxOf(tester, 'dir'));
      await tester.pump();
      expect(h.checked, {'dir/a', 'dir/sub/b', 'dir/sub/c'});
      await tester.tapAt(_checkboxOf(tester, 'dir'));
      await tester.pump();
      expect(h.checked, isEmpty);
    });

    testWidgets('a partly checked folder is mixed and checks fully next', (
      tester,
    ) async {
      final h = await pumpTree(
        tester,
        expanded: {'dir', 'dir/sub'},
        checked: {'dir/sub/b'},
      );
      expect(_stateOf(tester, 'sub'), DlmCheckState.mixed);
      expect(_stateOf(tester, 'dir'), DlmCheckState.mixed);
      expect(_stateOf(tester, 'b.txt'), DlmCheckState.checked);
      await tester.tapAt(_checkboxOf(tester, 'dir/sub'));
      await tester.pump();
      expect(h.checked, {'dir/sub/b', 'dir/sub/c'});
      expect(_stateOf(tester, 'sub'), DlmCheckState.checked);
      expect(_stateOf(tester, 'dir'), DlmCheckState.mixed);
    });

    testWidgets('a folder with all leaves checked is checked', (tester) async {
      await pumpTree(
        tester,
        expanded: {'dir', 'dir/sub'},
        checked: {'dir/a', 'dir/sub/b', 'dir/sub/c'},
      );
      expect(_stateOf(tester, 'dir'), DlmCheckState.checked);
    });

    testWidgets('a collapsed folder still reflects its hidden leaves', (
      tester,
    ) async {
      await pumpTree(tester, checked: {'dir/sub/c'});
      expect(_stateOf(tester, 'dir'), DlmCheckState.mixed);
    });

    testWidgets('keyboard: arrows expand, collapse and move', (tester) async {
      final h = await pumpTree(tester);
      await tester.tap(find.text('dir'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(h.expanded, {'dir'});
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(h.expanded, {'dir', 'dir/sub'});
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(h.expanded, {'dir'});
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(h.expanded, isEmpty, reason: 'left on an open folder collapses');
    });

    testWidgets('Left on a leaf moves to its parent', (tester) async {
      final h = await pumpTree(tester, expanded: {'dir'});
      await tester.tap(find.text('a.txt'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(h.expanded, isEmpty, reason: 'second Left collapsed the parent');
    });

    testWidgets('Space toggles the check of the cursor row', (tester) async {
      final h = await pumpTree(tester, expanded: {'dir'});
      await tester.tap(find.text('a.txt'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(h.checked, {'dir/a'});
    });

    testWidgets('Enter and double click activate', (tester) async {
      final h = await pumpTree(tester);
      await tester.tap(find.text('readme.md'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(h.activated, ['readme']);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('readme.md'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('readme.md'));
      await tester.pump(const Duration(seconds: 1));
      expect(h.activated.length, greaterThanOrEqualTo(2));
    });

    testWidgets('a tree without onCheckedChanged has no checkboxes', (
      tester,
    ) async {
      await pumpTree(tester, checkable: false);
      expect(find.byType(CustomPaint), findsWidgets);
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.text('readme.md')),
        isNot(matchesSemantics(hasCheckedState: true)),
      );
      handle.dispose();
    });

    testWidgets('rows announce expanded state and checkedness', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTree(tester, expanded: {'dir'}, checked: {'dir/a'});
      expect(
        tester.getSemantics(find.text('dir')),
        matchesSemantics(
          label: 'dir',
          hasExpandedState: true,
          isExpanded: true,
          hasCheckedState: true,
          isCheckStateMixed: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a tree of thousands of leaves builds only what is visible', (
      tester,
    ) async {
      final roots = [
        DlmTreeNode(
          id: 'big',
          label: 'big',
          children: [
            for (var i = 0; i < 20000; i++)
              DlmTreeNode(id: 'big/$i', label: 'file$i'),
          ],
        ),
      ];
      await pumpTree(tester, expanded: {'big'}, roots: roots);
      expect(find.textContaining('file').evaluate().length, lessThan(30));
    });

    testWidgets('indentation grows with depth', (tester) async {
      await pumpTree(tester, expanded: {'dir', 'dir/sub'});
      final dir = tester.getTopLeft(find.text('dir')).dx;
      final sub = tester.getTopLeft(find.text('sub')).dx;
      final b = tester.getTopLeft(find.text('b.txt')).dx;
      expect(sub, greaterThan(dir));
      expect(b, greaterThan(sub));
    });
  });

  group('DlmScheduleGrid', () {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String slotLabel(int s) => '${s.toString().padLeft(2, '0')}:00';

    Future<List<Set<int>>> pumpGrid(
      WidgetTester tester, {
      Set<int>? cells,
      double width = 900,
    }) async {
      final changes = <Set<int>>[];
      var current = cells ?? <int>{};
      await pumpKit(
        tester,
        size: Size(width + 100, 600),
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: width,
            height: 300,
            child: DlmScheduleGrid(
              cells: current,
              dayLabels: days,
              slotLabel: slotLabel,
              semanticLabel: 'Schedule',
              onChanged: (c) {
                changes.add(c);
                setState(() => current = c);
              },
            ),
          ),
        ),
      );
      return changes;
    }

    Offset cellCenter(WidgetTester tester, int day, int slot) {
      final topLeft = tester.getTopLeft(find.byType(DlmScheduleGrid));
      const label = 96.0;
      const cellWidth = (900 - label) / 24;
      const header = 11 + 12.0;
      return topLeft +
          Offset(label + cellWidth * (slot + 0.5), header + 24 * (day + 0.5));
    }

    testWidgets('clicking a cell toggles it', (tester) async {
      final changes = await pumpGrid(tester);
      await tester.tapAt(cellCenter(tester, 1, 9));
      await tester.pump();
      expect(changes.last, {24 + 9});
      await tester.tapAt(cellCenter(tester, 1, 9));
      await tester.pump();
      expect(changes.last, isEmpty);
    });

    testWidgets('dragging paints a range with the first cell\'s value', (
      tester,
    ) async {
      final changes = await pumpGrid(tester, cells: {5});
      final gesture = await tester.startGesture(cellCenter(tester, 0, 8));
      await gesture.moveTo(cellCenter(tester, 0, 10));
      await gesture.moveTo(cellCenter(tester, 0, 12));
      await gesture.up();
      await tester.pump();
      expect(changes.last, {5, 8, 9, 10, 11, 12});
    });

    testWidgets('dragging from a set cell clears the cells it crosses', (
      tester,
    ) async {
      final changes = await pumpGrid(tester, cells: {8, 9, 10, 11});
      final gesture = await tester.startGesture(cellCenter(tester, 0, 8));
      await gesture.moveTo(cellCenter(tester, 0, 10));
      await gesture.up();
      await tester.pump();
      expect(changes.last, {11});
    });

    testWidgets('clicking a day name toggles the whole day', (tester) async {
      final changes = await pumpGrid(tester);
      await tester.tap(find.text('Wed'));
      await tester.pump();
      expect(changes.last.length, 24);
      expect(changes.last.every((c) => c ~/ 24 == 2), isTrue);
      await tester.tap(find.text('Wed'));
      await tester.pump();
      expect(changes.last, isEmpty);
    });

    testWidgets('keyboard: arrows move, Space toggles, Shift paints', (
      tester,
    ) async {
      final changes = await pumpGrid(tester);
      await tester.tapAt(cellCenter(tester, 0, 0));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes.last, {0, 1});
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(changes.last, containsAll([0, 1, 24 + 1, 24 + 2, 24 + 3]));
    });

    testWidgets('Home and End jump to the ends of the day', (tester) async {
      final changes = await pumpGrid(tester);
      await tester.tapAt(cellCenter(tester, 2, 5));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes.last, {2 * 24 + 5, 2 * 24 + 23, 2 * 24});
    });

    testWidgets('every cell is an announced checkbox-like node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpGrid(tester, cells: {9});
      expect(
        tester.getSemantics(find.bySemanticsLabel('Mon 09:00')),
        matchesSemantics(
          label: 'Mon 09:00',
          hasCheckedState: true,
          isChecked: true,
          hasTapAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Sun 23:00'), findsOneWidget);
      expect(find.bySemanticsLabel('Schedule'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('narrow containers scroll horizontally instead of squeezing', (
      tester,
    ) async {
      await pumpGrid(tester, width: 300);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('half-hour slots work', (tester) async {
      final changes = <Set<int>>[];
      await pumpKit(
        tester,
        SizedBox(
          width: 1200,
          height: 300,
          child: DlmScheduleGrid(
            cells: const {},
            slotsPerDay: 48,
            dayLabels: days,
            slotLabel: (s) => '$s',
            semanticLabel: 'Schedule',
            onChanged: changes.add,
          ),
        ),
      );
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Mon 47'), findsOneWidget);
      handle.dispose();
    });
  });

  group('chart frame', () {
    testWidgets('shows title, legend and the chart; summary is the text '
        'alternative', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const SizedBox(
          width: 400,
          child: DlmChartFrame(
            title: 'Speed',
            summary: 'Peak 12 MB/s at 14:05, average 4 MB/s.',
            legend: [
              DlmLegendItem(label: 'Down', color: Color(0xFF0072B2)),
              DlmLegendItem(label: 'Up', color: Color(0xFFE69F00)),
            ],
            child: ColoredBox(key: Key('chart'), color: Color(0xFF000000)),
          ),
        ),
      );
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Down'), findsOneWidget);
      expect(find.byKey(const Key('chart')), findsOneWidget);
      expect(
        find.bySemanticsLabel('Peak 12 MB/s at 14:05, average 4 MB/s.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Down'), findsNothing);
      handle.dispose();
    });

    for (final brightness in Brightness.values) {
      for (final contrast in DlmContrast.values) {
        test('palette is readable and distinct (${brightness.name}/'
            '${contrast.name})', () {
          final colors = const TestSkin()
              .tokens(DlmAppearance(brightness: brightness, contrast: contrast))
              .colors;
          final palette = DlmChartPalette.forColors(colors);
          final min = contrast == DlmContrast.high ? 4.5 : 3.0;
          for (final c in palette.series) {
            expect(contrastRatio(c, colors.content), greaterThanOrEqualTo(min));
          }
          expect(palette.series.toSet().length, palette.series.length);
          expect(palette[0], palette[palette.series.length]);
        });
      }
    }
  });
}

Offset _checkboxOf(WidgetTester tester, String id) =>
    tester.getCenter(find.byKey(ValueKey('dlm-tree-check-$id')));

DlmCheckState _stateOf(WidgetTester tester, String label) {
  final row = find.ancestor(
    of: find.text(label),
    matching: find.byType(Semantics),
  );
  final node = tester.getSemantics(row.first);
  return switch (node.getSemanticsData().flagsCollection.isChecked) {
    CheckedState.mixed => DlmCheckState.mixed,
    CheckedState.isTrue => DlmCheckState.checked,
    _ => DlmCheckState.unchecked,
  };
}
