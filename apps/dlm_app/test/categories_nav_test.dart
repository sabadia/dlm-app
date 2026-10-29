import 'package:dlm_api/dlm_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  appTest('a category is a page of the sidebar that filters the list', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      queues: [queue('main', 'Default')],
      categories: const [
        Category(
          dir: '/media',
          id: 'c1',
          name: 'Media',
          position: 0,
          extensions: ['mkv'],
        ),
      ],
      tasks: [task('a', name: 'one.iso')],
    );
    // The section of categories and the Manage entry of their page.
    expect(find.text('Categories'), findsNWidgets(2));
    await tester.tap(find.text('Media'));
    await settle(tester);
    expect(h.tasks.listCalls.last.$1.category, 'c1');
  });

  appTest('without categories the sidebar has no section for them', (
    tester,
  ) async {
    await pumpApp(tester);
    // Only the Manage entry is left.
    expect(find.text('Categories'), findsOneWidget);
  });

  appTest('Tools lists the things to do, and a click opens one', (
    tester,
  ) async {
    // A tall window, so the whole sidebar is built.
    await pumpApp(tester, size: const Size(1400, 2400));
    expect(find.text('Tools'), findsOneWidget);
    for (final t in ['Browser tool', 'Import and export', 'Statistics']) {
      expect(find.text(t), findsOneWidget);
    }
    await tester.tap(find.text('Statistics'));
    await settle(tester);
    // The sidebar entry and the page title.
    expect(find.text('Statistics'), findsNWidgets(2));
  });
}
