import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('DlmSidebar', () {
    Widget sidebar(
      ValueChanged<String> onSelected, {
      String? selected = 'all',
      int? active,
    }) => SizedBox(
      width: 220,
      height: 400,
      child: DlmSidebar<String>(
        semanticLabel: 'Navigation',
        selected: selected,
        onSelected: onSelected,
        header: const Text('dlm'),
        footer: const Text('Connected'),
        sections: [
          DlmSidebarSection(
            items: [
              const DlmSidebarItem(id: 'all', label: 'All'),
              DlmSidebarItem(id: 'active', label: 'Active', count: active),
            ],
          ),
          const DlmSidebarSection(
            title: 'Queues',
            items: [DlmSidebarItem(id: 'night', label: 'Night')],
          ),
        ],
      ),
    );

    testWidgets('shows header, sections, items and footer', (tester) async {
      await pumpKit(tester, sidebar((_) {}));
      for (final t in [
        'dlm',
        'All',
        'Active',
        'Queues',
        'Night',
        'Connected',
      ]) {
        expect(find.text(t), findsOneWidget);
      }
    });

    testWidgets('choosing an item reports its id', (tester) async {
      String? chosen;
      await pumpKit(tester, sidebar((v) => chosen = v));
      await tester.tap(find.text('Night'));
      expect(chosen, 'night');
    });

    testWidgets('arrow keys move focus and Enter chooses', (tester) async {
      String? chosen;
      await pumpKit(tester, sidebar((v) => chosen = v));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(chosen, 'active');
    });

    testWidgets('counts show as badges and are announced; zero is hidden', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpKit(tester, sidebar((_) {}, active: 12));
      expect(find.text('12'), findsOneWidget);
      expect(find.bySemanticsLabel('Active, 12'), findsOneWidget);
      await pumpKit(tester, sidebar((_) {}, active: 0));
      await tester.pump();
      expect(find.text('0'), findsNothing);
      handle.dispose();
    });

    testWidgets('large counts are capped', (tester) async {
      await pumpKit(tester, sidebar((_) {}, active: 12345));
      expect(find.text('999+'), findsOneWidget);
    });

    testWidgets('selection is announced and the landmark is named', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpKit(tester, sidebar((_) {}));
      expect(find.bySemanticsLabel('Navigation'), findsOneWidget);
      expect(
        tester.getSemantics(find.widgetWithText(DlmInteractive, 'All')),
        matchesSemantics(
          label: 'All',
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a translucent sidebar material is tinted, not opaque', (
      tester,
    ) async {
      await pumpKit(tester, sidebar((_) {}));
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(DlmSidebar<String>),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final color = (box.decoration as BoxDecoration).color!;
      expect(color.a, closeTo(0.7, 0.01));
    });

    testWidgets('reduce transparency makes the sidebar opaque', (tester) async {
      await pumpKit(
        tester,
        sidebar((_) {}),
        appearance: const DlmAppearance(reduceTransparency: true),
      );
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(DlmSidebar<String>),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((box.decoration as BoxDecoration).color!.a, 1);
    });
  });

  group('DlmToolbar', () {
    testWidgets('lays out leading, title and actions in order', (tester) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 600,
          child: DlmToolbar(
            leading: const [SizedBox(key: Key('lead'), width: 20, height: 20)],
            title: 'Downloads',
            actions: [
              DlmButton(label: 'Add', onPressed: () {}),
              DlmButton(label: 'Pause', onPressed: () {}),
            ],
          ),
        ),
      );
      final lead = tester.getRect(find.byKey(const Key('lead')));
      final title = tester.getRect(find.text('Downloads'));
      final add = tester.getRect(find.text('Add'));
      final pause = tester.getRect(find.text('Pause'));
      expect(lead.right, lessThan(title.left));
      expect(title.right, lessThan(add.left));
      expect(add.right, lessThan(pause.left));
      expect(tester.getSize(find.byType(DlmToolbar)).height, 40);
    });

    testWidgets('the title is a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const SizedBox(width: 400, child: DlmToolbar(title: 'Downloads')),
      );
      expect(
        tester.getSemantics(find.text('Downloads')),
        matchesSemantics(label: 'Downloads', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('a long title is ellipsised', (tester) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 200,
          child: DlmToolbar(
            title: 'x' * 200,
            actions: [DlmButton(label: 'Add', onPressed: () {})],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('forms', () {
    testWidgets('a group shows its title, rows, separators and footer', (
      tester,
    ) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 600,
          child: DlmFormGroup(
            title: 'Speed',
            footer: 'Applies to new downloads.',
            children: [
              DlmFormRow(
                label: 'Connections',
                description: 'Per download',
                control: DlmSwitch(value: true, label: 'x', onChanged: (_) {}),
              ),
              DlmFormRow(
                label: 'Limit',
                control: DlmButton(label: 'Edit', onPressed: () {}),
              ),
            ],
          ),
        ),
      );
      for (final t in [
        'Speed',
        'Connections',
        'Per download',
        'Limit',
        'Applies to new downloads.',
      ]) {
        expect(find.text(t), findsOneWidget);
      }
    });

    testWidgets('a wide row puts the control at the trailing edge', (
      tester,
    ) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 600,
          child: DlmFormRow(
            label: 'Limit',
            control: DlmButton(label: 'Edit', onPressed: () {}),
          ),
        ),
      );
      expect(tester.getRect(find.text('Edit')).left, greaterThan(400));
    });

    testWidgets('a narrow row stacks the control under the text', (
      tester,
    ) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 300,
          child: DlmFormRow(
            label: 'Limit',
            control: DlmButton(label: 'Edit', onPressed: () {}),
          ),
        ),
      );
      expect(
        tester.getRect(find.text('Edit')).top,
        greaterThan(tester.getRect(find.text('Limit')).bottom),
      );
    });

    testWidgets('group titles are headings', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const SizedBox(
          width: 400,
          child: DlmFormGroup(title: 'Speed', children: [Text('row')]),
        ),
      );
      expect(
        tester.getSemantics(find.text('Speed')),
        matchesSemantics(label: 'Speed', isHeader: true),
      );
      handle.dispose();
    });
  });

  group('DlmSplitView', () {
    Future<List<double>> pumpSplit(
      WidgetTester tester, {
      bool atEnd = false,
      Axis axis = Axis.horizontal,
      double start = 200,
      double minSecondary = 240,
    }) async {
      final seen = <double>[];
      var size = start;
      await pumpKit(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 800,
            height: 400,
            child: DlmSplitView(
              axis: axis,
              primaryAtEnd: atEnd,
              minSecondary: minSecondary,
              primarySize: size,
              initialSize: 200,
              dividerLabel: 'Resize',
              onResized: (v) {
                seen.add(v);
                setState(() => size = v);
              },
              primary: const ColoredBox(
                key: Key('primary'),
                color: Color(0xFF123456),
              ),
              secondary: const ColoredBox(
                key: Key('secondary'),
                color: Color(0xFF654321),
              ),
            ),
          ),
        ),
      );
      return seen;
    }

    testWidgets('sizes the primary pane and gives the rest to the secondary', (
      tester,
    ) async {
      await pumpSplit(tester);
      expect(tester.getSize(find.byKey(const Key('primary'))).width, 200);
      expect(
        tester.getSize(find.byKey(const Key('secondary'))).width,
        closeTo(800 - 200 - 8, 0.5),
      );
    });

    testWidgets('dragging the divider resizes within the limits', (
      tester,
    ) async {
      final seen = await pumpSplit(tester);
      final divider = tester.getCenter(find.byType(FocusableActionDetector));
      await tester.dragFrom(divider, const Offset(100, 0));
      expect(seen.last, closeTo(300 - kTouchSlop, 2));
      await tester.dragFrom(
        tester.getCenter(find.byType(FocusableActionDetector)),
        const Offset(2000, 0),
      );
      expect(seen.last, 800 - 240);
      await tester.dragFrom(
        tester.getCenter(find.byType(FocusableActionDetector)),
        const Offset(-3000, 0),
      );
      expect(seen.last, 160);
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('an end-anchored pane grows when dragged toward the start', (
      tester,
    ) async {
      final seen = await pumpSplit(tester, atEnd: true);
      await tester.dragFrom(
        tester.getCenter(find.byType(FocusableActionDetector)),
        const Offset(-50, 0),
      );
      expect(seen.last, closeTo(250 - kTouchSlop, 2));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('arrow keys resize by 16, Home/End jump', (tester) async {
      final seen = await pumpSplit(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(seen.last, 216);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(seen.last, 184);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      expect(seen.last, 160);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      expect(seen.last, 800 - 240);
    });

    testWidgets('double click restores the initial size', (tester) async {
      final seen = await pumpSplit(tester, start: 350);
      final divider = tester.getCenter(find.byType(FocusableActionDetector));
      await tester.tapAt(divider);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(divider);
      await tester.pump(const Duration(milliseconds: 400));
      expect(seen.last, 200);
    });

    testWidgets('a vertical split works the same way', (tester) async {
      final seen = await pumpSplit(
        tester,
        axis: Axis.vertical,
        minSecondary: 100,
      );
      await tester.dragFrom(
        tester.getCenter(find.byType(FocusableActionDetector)),
        const Offset(0, 60),
      );
      expect(seen.last, closeTo(260 - kTouchSlop, 2));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('the divider exposes a labelled adjustable value', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final seen = await pumpSplit(tester);
      final node = tester.getSemantics(find.byType(FocusableActionDetector));
      expect(node.label, 'Resize');
      expect(node.value, '200');
      tester.semantics.increase(find.semantics.byLabel('Resize'));
      await tester.pump();
      expect(seen.last, 216);
      handle.dispose();
    });

    testWidgets('a size outside the limits is clamped when shown', (
      tester,
    ) async {
      await pumpSplit(tester, start: 5000);
      expect(tester.getSize(find.byKey(const Key('primary'))).width, 800 - 240);
    });
  });
}
