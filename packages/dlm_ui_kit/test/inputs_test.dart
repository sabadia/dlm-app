import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('DlmTextField', () {
    testWidgets('typing reports changes and hides the placeholder', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpKit(
        tester,
        SizedBox(
          width: 300,
          child: DlmTextField(
            placeholder: 'Name',
            semanticLabel: 'Name',
            onChanged: changes.add,
          ),
        ),
      );
      expect(find.text('Name'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      expect(changes, ['abc']);
      expect(find.text('Name'), findsNothing);
    });

    testWidgets('tapping the padding of the frame focuses the editor', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await pumpKit(
        tester,
        SizedBox(width: 300, child: DlmTextField(focusNode: focus)),
      );
      await tester.tapAt(
        tester.getTopLeft(find.byType(DlmTextField)) + const Offset(3, 3),
      );
      await tester.pump();
      expect(focus.hasFocus, isTrue);
    });

    testWidgets('a disabled field is read-only and unfocusable by tap', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await pumpKit(
        tester,
        SizedBox(
          width: 300,
          child: DlmTextField(focusNode: focus, enabled: false),
        ),
      );
      await tester.tap(find.byType(DlmTextField));
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).readOnly,
        isTrue,
      );
      expect(focus.hasFocus, isFalse);
    });

    testWidgets('shows the error text in a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const SizedBox(
          width: 300,
          child: DlmTextField(errorText: 'Required', semanticLabel: 'Name'),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Required')),
        matchesSemantics(label: 'Required', isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('multiline fields keep their frame taller than one row', (
      tester,
    ) async {
      await pumpKit(
        tester,
        const SizedBox(
          width: 300,
          child: DlmTextField(maxLines: null, minLines: 4),
        ),
      );
      expect(
        tester.getSize(find.byType(DlmTextField)).height,
        greaterThan(28 * 2),
      );
    });

    testWidgets('the field keeps its text when the theme changes', (
      tester,
    ) async {
      final source = await pumpKit(
        tester,
        const SizedBox(width: 300, child: DlmTextField()),
      );
      await tester.enterText(find.byType(EditableText), 'keep');
      source.update(const DlmAppearance(brightness: Brightness.dark));
      await tester.pump();
      expect(find.text('keep'), findsOneWidget);
    });
  });

  group('DlmSearchField', () {
    testWidgets('shows a clear button only while there is text', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpKit(
        tester,
        SizedBox(
          width: 300,
          child: DlmSearchField(onChanged: changes.add, clearLabel: 'Clear'),
        ),
      );
      expect(find.byType(DlmIconButton), findsNothing);
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      expect(find.byType(DlmIconButton), findsOneWidget);
      await tester.tap(find.byType(DlmIconButton));
      await tester.pump();
      expect(changes.last, '');
      expect(find.byType(DlmIconButton), findsNothing);
    });

    testWidgets('Escape clears', (tester) async {
      final changes = <String>[];
      await pumpKit(
        tester,
        SizedBox(
          width: 300,
          child: DlmSearchField(
            onChanged: changes.add,
            clearLabel: 'Clear',
            semanticLabel: 'Search',
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(changes.last, '');
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
    });
  });

  group('DlmPasswordField', () {
    testWidgets('is hidden until revealed and names the toggle', (
      tester,
    ) async {
      await pumpKit(
        tester,
        const SizedBox(
          width: 300,
          child: DlmPasswordField(showLabel: 'Show', hideLabel: 'Hide'),
        ),
      );
      bool obscured() =>
          tester.widget<EditableText>(find.byType(EditableText)).obscureText;
      expect(obscured(), isTrue);
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Show'), findsOneWidget);
      await tester.tap(find.byType(DlmIconButton));
      await tester.pump();
      expect(obscured(), isFalse);
      expect(find.bySemanticsLabel('Hide'), findsOneWidget);
      handle.dispose();
    });
  });

  group('DlmParsedField', () {
    int? parse(String t) => int.tryParse(t);
    Widget field({
      required ValueChanged<int?> onChanged,
      int? value,
      bool allowEmpty = false,
    }) => SizedBox(
      width: 300,
      child: DlmParsedField<int>(
        value: value,
        onChanged: onChanged,
        parse: parse,
        format: (v) => v.toString().padLeft(3, '0'),
        invalidText: 'Not a number',
        allowEmpty: allowEmpty,
      ),
    );

    testWidgets('reports valid values while typing, errors only on blur', (
      tester,
    ) async {
      final seen = <int?>[];
      await pumpKit(
        tester,
        Column(
          children: [
            field(onChanged: seen.add),
            const DlmTextField(),
          ],
        ),
      );
      await tester.tap(find.byType(EditableText).first);
      await tester.enterText(find.byType(EditableText).first, '12');
      await tester.pump();
      expect(seen, [12]);
      await tester.enterText(find.byType(EditableText).first, '12x');
      await tester.pump();
      expect(find.text('Not a number'), findsNothing);
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(find.text('Not a number'), findsOneWidget);
      expect(seen, [12], reason: 'invalid text is never reported');
    });

    testWidgets('a valid entry is rewritten canonically on blur', (
      tester,
    ) async {
      await pumpKit(
        tester,
        Column(
          children: [
            field(onChanged: (_) {}),
            const DlmTextField(),
          ],
        ),
      );
      await tester.tap(find.byType(EditableText).first);
      await tester.enterText(find.byType(EditableText).first, '7');
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(find.text('007'), findsOneWidget);
    });

    testWidgets('empty is invalid unless allowed, and then reports null', (
      tester,
    ) async {
      final seen = <int?>[];
      await pumpKit(
        tester,
        Column(
          children: [
            field(value: 5, onChanged: seen.add, allowEmpty: true),
            const DlmTextField(),
          ],
        ),
      );
      await tester.tap(find.byType(EditableText).first);
      await tester.enterText(find.byType(EditableText).first, '');
      await tester.pump();
      expect(seen, [null]);
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(find.text('Not a number'), findsNothing);
    });

    testWidgets('an external value change rewrites the text', (tester) async {
      await pumpKit(tester, field(value: 1, onChanged: (_) {}));
      expect(find.text('001'), findsOneWidget);
      await pumpKit(tester, field(value: 9, onChanged: (_) {}));
      await tester.pump();
      expect(find.text('009'), findsOneWidget);
    });
  });

  group('DlmNumberField', () {
    Future<List<num?>> pumpNumber(
      WidgetTester tester, {
      num? min,
      num? max,
      int decimals = 0,
    }) async {
      final seen = <num?>[];
      await pumpKit(
        tester,
        Column(
          children: [
            SizedBox(
              width: 300,
              child: DlmNumberField(
                value: null,
                onChanged: seen.add,
                invalidText: 'Out of range',
                min: min,
                max: max,
                decimals: decimals,
              ),
            ),
            const DlmTextField(),
          ],
        ),
      );
      await tester.tap(find.byType(EditableText).first);
      return seen;
    }

    testWidgets('accepts integers inside the bounds only', (tester) async {
      final seen = await pumpNumber(tester, min: 1, max: 16);
      for (final text in ['0', '8', '17', '1.5', 'x', '16']) {
        await tester.enterText(find.byType(EditableText).first, text);
      }
      await tester.pump();
      expect(seen, [8, 16]);
    });

    testWidgets('accepts decimals when asked', (tester) async {
      final seen = await pumpNumber(tester, min: 0, decimals: 2);
      await tester.enterText(find.byType(EditableText).first, '1.25');
      await tester.enterText(find.byType(EditableText).first, '-1');
      await tester.pump();
      expect(seen, [1.25]);
    });

    testWidgets('right-aligns its text', (tester) async {
      await pumpNumber(tester);
      expect(
        tester.widget<EditableText>(find.byType(EditableText).first).textAlign,
        TextAlign.end,
      );
    });
  });

  group('DlmSlider', () {
    Future<List<double>> pumpSlider(
      WidgetTester tester, {
      double value = 0.5,
      int? divisions,
      bool enabled = true,
    }) async {
      final seen = <double>[];
      var current = value;
      await pumpKit(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 220,
            child: DlmSlider(
              value: current,
              divisions: divisions,
              semanticLabel: 'Volume',
              onChanged: enabled
                  ? (v) {
                      seen.add(v);
                      setState(() => current = v);
                    }
                  : null,
            ),
          ),
        ),
      );
      return seen;
    }

    testWidgets('tapping sets the value across the usable track', (
      tester,
    ) async {
      final seen = await pumpSlider(tester);
      final left = tester.getTopLeft(find.byType(DlmSlider));
      await tester.tapAt(left + const Offset(210, 14));
      expect(seen.last, closeTo(1, 0.05));
      await tester.tapAt(left + const Offset(0, 14));
      expect(seen.last, 0);
    });

    testWidgets('dragging follows the pointer and clamps', (tester) async {
      final seen = await pumpSlider(tester, value: 0);
      final start =
          tester.getTopLeft(find.byType(DlmSlider)) + const Offset(10, 14);
      await tester.dragFrom(start, const Offset(400, 0));
      expect(seen.last, 1);
    });

    testWidgets('arrow, page and home/end keys move the value', (tester) async {
      final seen = await pumpSlider(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(seen.last, closeTo(0.6, 1e-9));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(seen.last, closeTo(0.4, 1e-9));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      expect(seen.last, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      expect(seen.last, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      expect(seen.last, 1);
    });

    testWidgets('divisions snap to whole steps', (tester) async {
      final seen = await pumpSlider(tester, value: 0, divisions: 4);
      final left = tester.getTopLeft(find.byType(DlmSlider));
      await tester.tapAt(left + const Offset(100, 14));
      expect(seen.last, anyOf(0.5, 0.25));
      expect((seen.last * 4) % 1, 0);
    });

    testWidgets('exposes value and increase/decrease actions', (tester) async {
      final handle = tester.ensureSemantics();
      final seen = await pumpSlider(tester);
      final node = tester.getSemantics(find.byType(DlmSlider));
      expect(
        node,
        matchesSemantics(
          label: 'Volume',
          value: '0.5',
          isSlider: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
          increasedValue: '0.6',
          decreasedValue: '0.4',
        ),
      );
      tester.semantics.increase(find.semantics.byLabel('Volume'));
      await tester.pump();
      expect(seen.last, closeTo(0.6, 1e-9));
      handle.dispose();
    });

    testWidgets('disabled sliders ignore input', (tester) async {
      final seen = await pumpSlider(tester, enabled: false);
      await tester.tap(find.byType(DlmSlider));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(seen, isEmpty);
    });
  });

  group('DlmIcon', () {
    testWidgets('draws every built-in glyph without semantics noise', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        Wrap(
          children: [for (final n in DlmIconName.values) DlmIcon(n, size: 20)],
        ),
      );
      expect(find.byType(DlmIcon), findsNWidgets(DlmIconName.values.length));
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(RegExp('.')), findsNothing);
      handle.dispose();
    });
  });
}
