import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

List<DlmMenuEntry> _entries(List<String> log) => [
  const DlmMenuHeader('File'),
  DlmMenuItem(
    label: 'Open',
    shortcut: 'Ctrl+O',
    onPressed: () => log.add('open'),
  ),
  DlmMenuItem(label: 'Rename', onPressed: () => log.add('rename')),
  const DlmMenuItem(label: 'Locked', onPressed: null),
  const DlmMenuSeparator(),
  DlmMenuItem(
    label: 'Delete',
    destructive: true,
    onPressed: () => log.add('delete'),
  ),
];

void main() {
  group('DlmPopover', () {
    testWidgets('opens below its anchor and closes on outside click', (
      tester,
    ) async {
      final controller = DlmPopoverController();
      await pumpKit(
        tester,
        Padding(
          padding: const EdgeInsets.all(50),
          child: DlmPopover(
            controller: controller,
            popoverBuilder: (_) => const Text('Content'),
            child: const SizedBox(key: Key('anchor'), width: 80, height: 30),
          ),
        ),
      );
      controller.show();
      await tester.pump();
      expect(find.text('Content'), findsOneWidget);
      final anchor = tester.getRect(find.byKey(const Key('anchor')));
      final content = tester.getRect(find.text('Content'));
      expect(content.top, greaterThan(anchor.bottom));
      expect(content.left, closeTo(anchor.left + 12, 14));
      await tester.tapAt(const Offset(700, 500));
      await tester.pump();
      expect(find.text('Content'), findsNothing);
      expect(controller.isShowing, isFalse);
    });

    testWidgets('opens above when there is no room below', (tester) async {
      final controller = DlmPopoverController();
      await pumpKit(
        tester,
        Padding(
          padding: const EdgeInsets.only(top: 540, left: 50),
          child: DlmPopover(
            controller: controller,
            maxHeight: 200,
            popoverBuilder: (_) =>
                const SizedBox(height: 100, child: Text('Content')),
            child: const SizedBox(key: Key('anchor'), width: 80, height: 30),
          ),
        ),
      );
      controller.show();
      await tester.pump();
      expect(
        tester.getRect(find.text('Content')).bottom,
        lessThan(tester.getRect(find.byKey(const Key('anchor'))).top),
      );
    });

    testWidgets('Escape closes it and focus returns to the trigger', (
      tester,
    ) async {
      final controller = DlmPopoverController();
      final trigger = FocusNode();
      addTearDown(trigger.dispose);
      var dismissed = 0;
      await pumpKit(
        tester,
        DlmPopover(
          controller: controller,
          onDismissed: () => dismissed++,
          popoverBuilder: (_) => const DlmTextField(),
          child: DlmButton(
            label: 'Open',
            focusNode: trigger,
            onPressed: controller.show,
          ),
        ),
      );
      trigger.requestFocus();
      await tester.pump();
      controller.show();
      await tester.pump();
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(trigger.hasFocus, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(controller.isShowing, isFalse);
      expect(trigger.hasFocus, isTrue);
      expect(dismissed, 1);
    });

    testWidgets('can match the anchor width', (tester) async {
      final controller = DlmPopoverController();
      await pumpKit(
        tester,
        DlmPopover(
          controller: controller,
          matchAnchorWidth: true,
          popoverBuilder: (_) => const Text('x'),
          child: const SizedBox(key: Key('anchor'), width: 300, height: 30),
        ),
      );
      controller.show();
      await tester.pump();
      final surface = find.ancestor(
        of: find.text('x'),
        matching: find.byType(ConstrainedBox),
      );
      expect(tester.getSize(surface.first).width, greaterThanOrEqualTo(300));
    });
  });

  group('DlmMenuButton', () {
    testWidgets('opens, focuses the first enabled item, runs a choice', (
      tester,
    ) async {
      final log = <String>[];
      await pumpKit(
        tester,
        DlmMenuButton(label: 'Actions', entries: _entries(log)),
      );
      await tester.tap(find.text('Actions'));
      await tester.pump();
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Ctrl+O'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, ['open']);
      expect(find.text('Open'), findsNothing);
    });

    testWidgets('arrow keys skip disabled items; Enter activates', (
      tester,
    ) async {
      final log = <String>[];
      await pumpKit(
        tester,
        DlmMenuButton(label: 'Actions', entries: _entries(log)),
      );
      await tester.tap(find.text('Actions'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, ['delete'], reason: 'Locked is skipped');
    });

    testWidgets('typing a letter jumps to the matching item', (tester) async {
      final log = <String>[];
      await pumpKit(
        tester,
        DlmMenuButton(label: 'Actions', entries: _entries(log)),
      );
      await tester.tap(find.text('Actions'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, ['rename']);
    });

    testWidgets('a disabled item cannot be chosen', (tester) async {
      final log = <String>[];
      await pumpKit(
        tester,
        DlmMenuButton(label: 'Actions', entries: _entries(log)),
      );
      await tester.tap(find.text('Actions'));
      await tester.pump();
      await tester.tap(find.text('Locked'));
      await tester.pump();
      expect(log, isEmpty);
      expect(find.text('Open'), findsOneWidget, reason: 'menu stays open');
    });

    testWidgets('items are announced as menu items; headers as headers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        DlmMenuButton(label: 'Actions', entries: _entries([])),
      );
      await tester.tap(find.text('Actions'));
      await tester.pump();
      expect(
        tester.getSemantics(find.widgetWithText(DlmInteractive, 'Rename')),
        matchesSemantics(
          label: 'Rename',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('File')),
        matchesSemantics(label: 'File', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('checked items reserve a check column', (tester) async {
      await pumpKit(
        tester,
        DlmMenuButton(
          label: 'View',
          entries: [
            DlmMenuItem(label: 'A', checked: true, onPressed: () {}),
            DlmMenuItem(label: 'B', checked: false, onPressed: () {}),
          ],
        ),
      );
      await tester.tap(find.text('View'));
      await tester.pump();
      expect(
        tester.getTopLeft(find.text('A')).dx,
        tester.getTopLeft(find.text('B')).dx,
      );
    });
  });

  group('DlmSplitButton', () {
    testWidgets('main part and arrow are separate actions', (tester) async {
      var main = 0;
      final log = <String>[];
      await pumpKit(
        tester,
        DlmSplitButton(
          label: 'Add',
          onPressed: () => main++,
          menuLabel: 'More options',
          entries: [
            DlmMenuItem(label: 'Add paused', onPressed: () => log.add('p')),
          ],
        ),
      );
      await tester.tap(find.text('Add'));
      expect(main, 1);
      await tester.tap(find.byType(DlmIconButton));
      await tester.pump();
      await tester.tap(find.text('Add paused'));
      await tester.pump();
      expect(log, ['p']);
      expect(main, 1);
    });
  });

  group('DlmContextMenuRegion', () {
    Future<void> pumpRegion(WidgetTester tester, List<String> log) => pumpKit(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: DlmContextMenuRegion(
          entries: () => _entries(log),
          child: const Focus(autofocus: true, child: SizedBox.expand()),
        ),
      ),
    );

    testWidgets('right click opens the menu at the pointer', (tester) async {
      final log = <String>[];
      await pumpRegion(tester, log);
      await tester.tapAt(const Offset(100, 100), buttons: kSecondaryButton);
      await tester.pump();
      expect(find.text('Rename'), findsOneWidget);
      expect(tester.getTopLeft(find.byType(DlmMenuPanel)).dx, closeTo(100, 1));
      await tester.tap(find.text('Rename'));
      await tester.pump();
      expect(log, ['rename']);
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('the Menu key opens it, Escape closes it', (tester) async {
      await pumpRegion(tester, []);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
      await tester.pump();
      expect(find.text('Rename'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('clicking elsewhere closes it without acting', (tester) async {
      final log = <String>[];
      await pumpRegion(tester, log);
      await tester.tapAt(const Offset(100, 100), buttons: kSecondaryButton);
      await tester.pump();
      await tester.tapAt(const Offset(700, 500));
      await tester.pump();
      expect(find.text('Rename'), findsNothing);
      expect(log, isEmpty);
    });

    testWidgets('stays on screen near the right and bottom edges', (
      tester,
    ) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 800,
          height: 600,
          child: DlmContextMenuRegion(
            entries: () => _entries([]),
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.tapAt(const Offset(795, 595), buttons: kSecondaryButton);
      await tester.pump();
      final rect = tester.getRect(find.byType(DlmMenuPanel));
      expect(rect.right, lessThanOrEqualTo(800));
      expect(rect.bottom, lessThanOrEqualTo(600));
    });

    testWidgets('an empty entry list shows nothing', (tester) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 300,
          height: 200,
          child: DlmContextMenuRegion(
            entries: () => const [],
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.tapAt(const Offset(100, 100), buttons: kSecondaryButton);
      await tester.pump();
      expect(find.byType(DlmMenuPanel), findsNothing);
    });
  });

  group('DlmDropdown', () {
    Widget dropdown({String? value, ValueChanged<String>? onChanged}) =>
        SizedBox(
          width: 220,
          child: DlmDropdown<String>(
            choices: const [
              DlmChoice(value: 'a', label: 'Alpha'),
              DlmChoice(value: 'b', label: 'Beta'),
            ],
            value: value,
            onChanged: onChanged,
            semanticLabel: 'Greek letter',
            placeholder: 'Choose',
          ),
        );

    testWidgets('shows the placeholder, then the selection', (tester) async {
      await pumpKit(tester, dropdown(onChanged: (_) {}));
      expect(find.text('Choose'), findsOneWidget);
      await pumpKit(tester, dropdown(value: 'b', onChanged: (_) {}));
      await tester.pump();
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('picking a choice reports it and closes', (tester) async {
      String? picked;
      await pumpKit(tester, dropdown(value: 'a', onChanged: (v) => picked = v));
      await tester.tap(find.text('Alpha'));
      await tester.pump();
      expect(find.text('Beta'), findsOneWidget);
      await tester.tap(find.text('Beta'));
      await tester.pump();
      expect(picked, 'b');
      expect(find.text('Beta'), findsNothing);
    });

    testWidgets('the menu is at least as wide as the trigger', (tester) async {
      await pumpKit(tester, dropdown(value: 'a', onChanged: (_) {}));
      await tester.tap(find.text('Alpha'));
      await tester.pump();
      expect(
        tester.getSize(find.byType(DlmMenuPanel)).width,
        greaterThanOrEqualTo(220),
      );
    });

    testWidgets('Arrow Down opens it from the keyboard', (tester) async {
      await pumpKit(tester, dropdown(value: 'a', onChanged: (_) {}));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(find.byType(DlmMenuPanel), findsOneWidget);
    });

    testWidgets('the selected choice is checked', (tester) async {
      await pumpKit(tester, dropdown(value: 'b', onChanged: (_) {}));
      await tester.tap(find.text('Beta'));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(DlmMenuPanel),
          matching: find.byType(DlmIcon),
        ),
        findsOneWidget,
      );
    });

    testWidgets('disabled when onChanged is null', (tester) async {
      await pumpKit(tester, dropdown(value: 'a'));
      await tester.tap(find.text('Alpha'));
      await tester.pump();
      expect(find.byType(DlmMenuPanel), findsNothing);
    });

    testWidgets('semantics name the control and its value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(tester, dropdown(value: 'a', onChanged: (_) {}));
      expect(find.bySemanticsLabel('Greek letter, Alpha'), findsOneWidget);
      handle.dispose();
    });
  });

  group('DlmComboBox', () {
    Future<List<String>> pumpCombo(WidgetTester tester) async {
      final picked = <String>[];
      await pumpKit(
        tester,
        SizedBox(
          width: 260,
          child: DlmComboBox<String>(
            semanticLabel: 'Category',
            choices: const [
              DlmChoice(value: 'video', label: 'Video'),
              DlmChoice(value: 'audio', label: 'Audio'),
              DlmChoice(value: 'archive', label: 'Archive'),
            ],
            onSelected: picked.add,
          ),
        ),
      );
      return picked;
    }

    testWidgets('typing filters the suggestions and keeps focus', (
      tester,
    ) async {
      await pumpCombo(tester);
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'ar');
      await tester.pump();
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Video'), findsNothing);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
    });

    testWidgets('arrows move the highlight and Enter picks it', (tester) async {
      final picked = await pumpCombo(tester);
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked.length, 1);
      expect(find.byType(DlmMenuPanel), findsNothing);
    });

    testWidgets('clicking a suggestion fills the field', (tester) async {
      final picked = await pumpCombo(tester);
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'v');
      await tester.pump();
      await tester.tap(find.text('Video'));
      await tester.pump();
      expect(picked, ['video']);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'Video',
      );
    });

    testWidgets('free text with no match opens nothing and is allowed', (
      tester,
    ) async {
      await pumpCombo(tester);
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pump();
      expect(find.byType(DlmMenuPanel), findsNothing);
    });

    testWidgets('Escape closes the list', (tester) async {
      await pumpCombo(tester);
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();
      expect(find.byType(DlmMenuPanel), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(DlmMenuPanel), findsNothing);
    });
  });

  group('dialogs', () {
    Widget opener(
      List<String> log, {
      bool dismissible = true,
      DlmDialogKind kind = DlmDialogKind.dialog,
    }) => Builder(
      builder: (context) => DlmButton(
        label: 'Open',
        onPressed: () async {
          final r = await showDlmDialog<String>(
            context,
            semanticLabel: 'Settings',
            kind: kind,
            barrierDismissible: dismissible,
            builder: (c) => DlmDialogContent(
              title: 'Title',
              message: 'Body',
              actions: [
                DlmButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(c).pop('closed'),
                ),
              ],
            ),
          );
          log.add(r ?? 'null');
        },
      ),
    );

    testWidgets('opens, returns the result, and removes itself', (
      tester,
    ) async {
      final log = <String>[];
      await pumpKit(tester, opener(log));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(log, ['closed']);
      expect(find.text('Title'), findsNothing);
    });

    testWidgets('Escape and the dimmed area dismiss with null', (tester) async {
      final log = <String>[];
      await pumpKit(tester, opener(log));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(log, ['null', 'null']);
    });

    testWidgets('a non-dismissible dialog ignores Escape and the barrier', (
      tester,
    ) async {
      final log = <String>[];
      await pumpKit(tester, opener(log, dismissible: false));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Title'), findsOneWidget);
      expect(log, isEmpty);
    });

    testWidgets('the dialog is a named route scope', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(tester, opener([]));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Title')),
        matchesSemantics(label: 'Title', isHeader: true),
      );
      expect(find.bySemanticsLabel('Settings'), findsWidgets);
      handle.dispose();
    });

    testWidgets('a sheet is attached to the top edge', (tester) async {
      await pumpKit(tester, opener([], kind: DlmDialogKind.sheet));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Title')).dy, lessThan(100));
    });

    testWidgets('reduce motion opens without a transition', (tester) async {
      await pumpKit(
        tester,
        opener([]),
        appearance: const DlmAppearance(reduceMotion: true),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('confirm resolves true, false and false on dismissal', (
      tester,
    ) async {
      final results = <bool>[];
      await pumpKit(
        tester,
        Builder(
          builder: (context) => DlmButton(
            label: 'Ask',
            onPressed: () async => results.add(
              await showDlmConfirm(
                context,
                title: 'Delete?',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
                destructive: true,
              ),
            ),
          ),
        ),
      );
      Future<void> ask() async {
        await tester.tap(find.text('Ask'));
        await tester.pumpAndSettle();
      }

      await ask();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await ask();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await ask();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(results, [true, false, false]);
    });

    testWidgets('a destructive confirm focuses Cancel, so Enter is safe', (
      tester,
    ) async {
      final results = <bool>[];
      await pumpKit(
        tester,
        Builder(
          builder: (context) => DlmButton(
            label: 'Ask',
            onPressed: () async => results.add(
              await showDlmConfirm(
                context,
                title: 'Delete?',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
                destructive: true,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(results, [false]);
    });

    testWidgets('a non-destructive confirm focuses the primary action', (
      tester,
    ) async {
      final results = <bool>[];
      await pumpKit(
        tester,
        Builder(
          builder: (context) => DlmButton(
            label: 'Ask',
            onPressed: () async => results.add(
              await showDlmConfirm(
                context,
                title: 'Proceed?',
                confirmLabel: 'Yes',
                cancelLabel: 'No',
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(results, [true]);
    });
  });
}
