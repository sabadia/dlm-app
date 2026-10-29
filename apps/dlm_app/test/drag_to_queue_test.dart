import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  final queues = [queue('main', 'Default'), queue('night', 'Night')];
  final tasks = [task('a', name: 'one.iso'), task('b', name: 'two.iso')];

  /// Drags the row named [name] sideways onto the sidebar item [target].
  Future<void> dragOnto(WidgetTester tester, String name, String target) async {
    final from = tester.getCenter(find.text(name));
    final to = tester.getCenter(find.text(target).first);
    final gesture = await tester.startGesture(from);
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(to);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await settle(tester);
  }

  appTest('dragging a download onto a queue moves it there', (tester) async {
    final h = await pumpApp(tester, queues: queues, tasks: tasks);
    await dragOnto(tester, 'one.iso', 'Night');
    expect(h.tasks.calls, ['moveMany:a:night']);
    expect(find.text('Moved 1 download to Night'), findsOneWidget);
  });

  appTest('dragging a selected row carries the whole selection', (
    tester,
  ) async {
    final h = await pumpApp(tester, queues: queues, tasks: tasks);
    h.container.read(selectionProvider.notifier).set({'a', 'b'});
    await tester.pump(const Duration(milliseconds: 100));
    await dragOnto(tester, 'one.iso', 'Night');
    expect(h.tasks.calls.single.startsWith('moveMany:'), isTrue);
    expect(h.tasks.calls.single.endsWith(':night'), isTrue);
    expect(find.text('Moved 2 downloads to Night'), findsOneWidget);
  });
}
