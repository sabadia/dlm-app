import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _labels = DlmPaletteLabels(
  placeholder: 'Type a command',
  noResults: 'No matching command',
  semanticLabel: 'Command palette',
);

void main() {
  final log = <String>[];
  late List<DlmCommand> commands;
  setUp(() {
    log.clear();
    commands = [
      DlmCommand(
        id: 'a',
        label: 'Go to Active',
        group: 'Navigate',
        onInvoke: () => log.add('active'),
      ),
      DlmCommand(
        id: 'b',
        label: 'Go to Completed',
        group: 'Navigate',
        keywords: const ['finished', 'done'],
        onInvoke: () => log.add('completed'),
      ),
      DlmCommand(
        id: 'c',
        label: 'Pause all',
        shortcut: 'Ctrl+P',
        onInvoke: () => log.add('pause'),
      ),
    ];
  });

  group('matchCommands', () {
    test('an empty query matches everything in order', () {
      expect(matchCommands(commands, '').map((c) => c.id), ['a', 'b', 'c']);
    });

    test('words must start a word of the label, group or a keyword', () {
      expect(matchCommands(commands, 'comp').map((c) => c.id), ['b']);
      expect(matchCommands(commands, 'nav').map((c) => c.id), ['a', 'b']);
      expect(matchCommands(commands, 'done').map((c) => c.id), ['b']);
      expect(matchCommands(commands, 'ause').map((c) => c.id), isEmpty);
    });

    test('every word has to match', () {
      expect(matchCommands(commands, 'go act').map((c) => c.id), ['a']);
      expect(matchCommands(commands, 'go pause').map((c) => c.id), isEmpty);
    });

    test('is case-insensitive and ignores extra spaces', () {
      expect(matchCommands(commands, '  PAUSE   ALL ').map((c) => c.id), ['c']);
    });

    test('labels that start with the query come first', () {
      final list = [
        DlmCommand(id: 'x', label: 'Open the folder', onInvoke: () {}),
        DlmCommand(id: 'y', label: 'Folder options', onInvoke: () {}),
      ];
      expect(matchCommands(list, 'fol').map((c) => c.id), ['y', 'x']);
    });
  });

  Future<void> open(WidgetTester tester) async {
    await pumpKit(
      tester,
      Builder(
        builder: (context) => DlmButton(
          label: 'Open',
          onPressed: () => showDlmCommandPalette(
            context,
            commands: commands,
            labels: _labels,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the commands with the search field focused', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Go to Active'), findsOneWidget);
    expect(find.text('Pause all'), findsOneWidget);
    expect(find.text('Ctrl+P'), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
  });

  testWidgets('typing filters, Enter runs the first match after closing', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(EditableText), 'comp');
    await tester.pump();
    expect(find.text('Go to Active'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(log, ['completed']);
    expect(find.text('Type a command'), findsNothing);
  });

  testWidgets('arrow keys move the highlight', (tester) async {
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(log, ['pause']);
  });

  testWidgets('the highlight wraps around', (tester) async {
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(log, ['pause']);
  });

  testWidgets('clicking a command runs it', (tester) async {
    await open(tester);
    await tester.tap(find.text('Pause all'));
    await tester.pumpAndSettle();
    expect(log, ['pause']);
  });

  testWidgets('Escape closes without running anything', (tester) async {
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(log, isEmpty);
    expect(find.text('Go to Active'), findsNothing);
  });

  testWidgets('no match shows the message and Enter does nothing', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(EditableText), 'zzzz');
    await tester.pump();
    expect(find.text('No matching command'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(log, isEmpty);
    expect(find.text('No matching command'), findsOneWidget);
  });

  testWidgets('commands announce their group', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    expect(find.bySemanticsLabel('Navigate: Go to Active'), findsOneWidget);
    expect(find.bySemanticsLabel('Command palette'), findsWidgets);
    handle.dispose();
  });
}
