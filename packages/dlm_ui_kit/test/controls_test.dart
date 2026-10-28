import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('DlmButton', () {
    for (final variant in DlmButtonVariant.values) {
      testWidgets('${variant.name} renders its label and fires', (
        tester,
      ) async {
        var pressed = 0;
        await pumpKit(
          tester,
          DlmButton(label: 'Go', variant: variant, onPressed: () => pressed++),
        );
        expect(find.text('Go'), findsOneWidget);
        await tester.tap(find.byType(DlmButton));
        expect(pressed, 1);
      });
    }

    testWidgets('onPressed null disables it', (tester) async {
      await pumpKit(tester, const DlmButton(label: 'Go', onPressed: null));
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(DlmButton)),
        matchesSemantics(label: 'Go', isButton: true, hasEnabledState: true),
      );
      handle.dispose();
    });

    testWidgets('sizes follow the metrics and density', (tester) async {
      await pumpKit(
        tester,
        Column(
          children: [
            for (final s in DlmControlSize.values)
              DlmButton(label: s.name, size: s, onPressed: () {}),
          ],
        ),
      );
      final heights = [
        for (final s in DlmControlSize.values)
          tester.getSize(find.widgetWithText(DlmButton, s.name)).height,
      ];
      expect(heights, [24, 28, 36]);
    });

    testWidgets('icon and label sit side by side', (tester) async {
      await pumpKit(
        tester,
        DlmButton(
          label: 'Add',
          icon: const SizedBox(key: Key('icon'), width: 16, height: 16),
          onPressed: () {},
        ),
      );
      final icon = tester.getRect(find.byKey(const Key('icon')));
      final text = tester.getRect(find.text('Add'));
      expect(icon.right, lessThan(text.left));
    });

    testWidgets('shows a focus ring only for keyboard focus', (tester) async {
      await pumpKit(tester, DlmButton(label: 'Go', onPressed: () {}));
      expect(find.byType(DlmFocusRing), findsOneWidget);
      expect(_ringVisible(tester), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_ringVisible(tester), isTrue);
    });
  });

  group('DlmIconButton', () {
    testWidgets('is square, named and fires', (tester) async {
      var pressed = 0;
      await pumpKit(
        tester,
        DlmIconButton(
          icon: const SizedBox(width: 16, height: 16),
          semanticLabel: 'Pause',
          onPressed: () => pressed++,
        ),
      );
      expect(tester.getSize(find.byType(DlmIconButton)), const Size(28, 28));
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Pause'), findsOneWidget);
      handle.dispose();
      await tester.tap(find.byType(DlmIconButton));
      expect(pressed, 1);
    });
  });

  group('DlmSwitch', () {
    testWidgets('toggles through onChanged and reports toggled state', (
      tester,
    ) async {
      var value = false;
      late StateSetter set;
      await pumpKit(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return DlmSwitch(
              value: value,
              label: 'Auto',
              onChanged: (v) => set(() => value = v),
            );
          },
        ),
      );
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(DlmSwitch)),
        matchesSemantics(
          label: 'Auto',
          hasToggledState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      await tester.tap(find.byType(DlmSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(
        tester.getSemantics(find.byType(DlmSwitch)),
        matchesSemantics(
          label: 'Auto',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('Space toggles when focused', (tester) async {
      var value = false;
      await pumpKit(
        tester,
        DlmSwitch(value: value, label: 'Auto', onChanged: (v) => value = v),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(value, isTrue);
    });

    testWidgets('onChanged null disables', (tester) async {
      await pumpKit(
        tester,
        const DlmSwitch(value: true, label: 'Auto', onChanged: null),
      );
      await tester.tap(find.byType(DlmSwitch));
      final focus = tester.widget<Focus>(
        find
            .descendant(
              of: find.byType(DlmSwitch),
              matching: find.byType(Focus),
            )
            .first,
      );
      expect(focus.canRequestFocus, isFalse);
    });
  });

  group('DlmCheckbox', () {
    testWidgets('unchecked and mixed become checked, checked unchecks', (
      tester,
    ) async {
      final seen = <DlmCheckState>[];
      for (final start in DlmCheckState.values) {
        await pumpKit(
          tester,
          DlmCheckbox(value: start, label: 'All', onChanged: seen.add),
        );
        await tester.tap(find.byType(DlmCheckbox));
        await tester.pump();
      }
      expect(seen, [
        DlmCheckState.checked,
        DlmCheckState.unchecked,
        DlmCheckState.checked,
      ]);
    });

    testWidgets('mixed is exposed to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        DlmCheckbox(
          value: DlmCheckState.mixed,
          label: 'All',
          onChanged: (_) {},
        ),
      );
      expect(
        tester.getSemantics(find.byType(DlmCheckbox)),
        matchesSemantics(
          label: 'All',
          hasCheckedState: true,
          isCheckStateMixed: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });
  });

  group('DlmRadio', () {
    testWidgets('chooses its value and reports checked', (tester) async {
      String? group = 'a';
      late StateSetter set;
      await pumpKit(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return Column(
              children: [
                for (final v in ['a', 'b'])
                  DlmRadio<String>(
                    value: v,
                    groupValue: group,
                    label: 'Option $v',
                    onChanged: (x) => set(() => group = x),
                  ),
              ],
            );
          },
        ),
      );
      await tester.tap(find.text('Option b'));
      await tester.pump();
      expect(group, 'b');
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.widgetWithText(DlmRadio<String>, 'Option b')),
        matchesSemantics(
          label: 'Option b',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: true,
        ),
      );
      handle.dispose();
    });
  });

  group('DlmSegmented', () {
    testWidgets('selects and announces the selected segment', (tester) async {
      var value = 'one';
      late StateSetter set;
      await pumpKit(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return DlmSegmented<String>(
              options: const [
                DlmOption(value: 'one', label: 'One'),
                DlmOption(value: 'two', label: 'Two'),
              ],
              value: value,
              onChanged: (v) => set(() => value = v),
            );
          },
        ),
      );
      await tester.tap(find.text('Two'));
      await tester.pump();
      expect(value, 'two');
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.widgetWithText(DlmInteractive, 'Two')),
        matchesSemantics(
          label: 'Two',
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
  });

  group('DlmTabBar', () {
    testWidgets('selects a tab', (tester) async {
      String? chosen;
      await pumpKit(
        tester,
        DlmTabBar<String>(
          tabs: const [
            DlmOption(value: 'a', label: 'A'),
            DlmOption(value: 'b', label: 'B'),
          ],
          value: 'a',
          onChanged: (v) => chosen = v,
        ),
      );
      await tester.tap(find.text('B'));
      expect(chosen, 'b');
    });
  });

  testWidgets('every control honours reduce motion', (tester) async {
    final source = await pumpKit(
      tester,
      const DlmSwitch(value: true, label: 'x', onChanged: null),
    );
    source.update(const DlmAppearance(reduceMotion: true));
    await tester.pump();
    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    expect(container.duration, Duration.zero);
  });
}

bool _ringVisible(WidgetTester tester) {
  final ring = tester.widget<DlmFocusRing>(find.byType(DlmFocusRing));
  return ring.visible;
}
