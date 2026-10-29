import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  final queues = [queue('main', 'Default')];
  final tasks = [
    task('a', name: 'one.iso'),
    task('b', name: 'two.iso', position: 1),
    task('c', name: 'three.iso', position: 2),
  ];

  Future<void> dragOnto(WidgetTester tester, String name, String target) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(name)),
    );
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(find.text(target)));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await settle(tester);
  }

  appTest('on a queue page a row dropped on another takes its place', (
    tester,
  ) async {
    final h = await pumpApp(tester, queues: queues, tasks: tasks);
    await tester.tap(find.text('Default').first);
    await settle(tester);
    await dragOnto(tester, 'one.iso', 'three.iso');
    expect(h.tasks.calls, contains('reorder:a:2'));
  });

  appTest('outside a queue page rows are not drop targets', (tester) async {
    final h = await pumpApp(tester, queues: queues, tasks: tasks);
    await dragOnto(tester, 'one.iso', 'three.iso');
    expect(h.tasks.calls.where((c) => c.startsWith('reorder')), isEmpty);
  });
}
