import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  late DlmStates last;
  var taps = 0;

  Widget probe({VoidCallback? onTap, bool enabled = true, bool hit = true}) =>
      DlmInteractive(
        onTap: onTap ?? () => taps++,
        enabled: enabled,
        ensureHitTarget: hit,
        semanticLabel: 'Probe',
        builder: (context, states) {
          last = states;
          return const SizedBox(width: 10, height: 10);
        },
      );

  setUp(() {
    taps = 0;
    last = DlmStates.idle;
  });

  testWidgets('a tap activates and tracks the pressed state', (tester) async {
    await pumpKit(tester, probe());
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(DlmInteractive)),
    );
    await tester.pump();
    expect(last.pressed, isTrue);
    await gesture.up();
    await tester.pump();
    expect(last.pressed, isFalse);
    expect(taps, 1);
  });

  testWidgets('dragging off cancels the press without activating', (
    tester,
  ) async {
    await pumpKit(tester, probe());
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(DlmInteractive)),
    );
    await gesture.moveTo(const Offset(500, 500));
    await gesture.up();
    await tester.pump();
    expect(last.pressed, isFalse);
    expect(taps, 0);
  });

  testWidgets('hover is tracked for a mouse pointer', (tester) async {
    await pumpKit(tester, probe());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(DlmInteractive)));
    await tester.pump();
    expect(last.hovered, isTrue);
    await mouse.moveTo(const Offset(700, 500));
    await tester.pump();
    expect(last.hovered, isFalse);
  });

  testWidgets('Enter and Space activate a focused control', (tester) async {
    await pumpKit(tester, probe());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(last.focused, isTrue);
    expect(last.focusVisible, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 2);
  });

  testWidgets('a disabled control ignores input and is not focusable', (
    tester,
  ) async {
    await pumpKit(tester, probe(enabled: false));
    await tester.tap(find.byType(DlmInteractive));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 0);
    expect(last.disabled, isTrue);
    expect(last.focused, isFalse);
  });

  testWidgets('a control without a callback is disabled', (tester) async {
    await pumpKit(
      tester,
      DlmInteractive(
        builder: (context, states) {
          last = states;
          return const SizedBox(width: 10, height: 10);
        },
      ),
    );
    expect(last.disabled, isTrue);
  });

  testWidgets('grows to the minimum hit target', (tester) async {
    await pumpKit(tester, probe());
    final size = tester.getSize(find.byType(DlmInteractive));
    expect(size.width, greaterThanOrEqualTo(24));
    expect(size.height, greaterThanOrEqualTo(24));
  });

  testWidgets('the hit target can be switched off for composed controls', (
    tester,
  ) async {
    await pumpKit(tester, probe(hit: false));
    expect(tester.getSize(find.byType(DlmInteractive)), const Size(10, 10));
  });

  testWidgets('exposes label, enabled and tap action to semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpKit(tester, probe());
    expect(
      tester.getSemantics(find.byType(DlmInteractive)),
      matchesSemantics(
        label: 'Probe',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('a disabled control is announced as disabled', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpKit(tester, probe(enabled: false));
    expect(
      tester.getSemantics(find.byType(DlmInteractive)),
      matchesSemantics(label: 'Probe', isButton: true, hasEnabledState: true),
    );
    handle.dispose();
  });

  testWidgets('secondary tap and double tap fire their callbacks', (
    tester,
  ) async {
    var secondary = 0;
    var doubled = 0;
    await pumpKit(
      tester,
      DlmInteractive(
        onSecondaryTap: () => secondary++,
        onDoubleTap: () => doubled++,
        builder: (context, states) => const SizedBox(width: 30, height: 30),
      ),
    );
    final center = tester.getCenter(find.byType(DlmInteractive));
    await tester.tapAt(center, buttons: kSecondaryButton);
    await tester.pump();
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 400));
    expect(secondary, 1);
    expect(doubled, 1);
  });
}
