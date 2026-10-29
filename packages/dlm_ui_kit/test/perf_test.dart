import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

String _resize(String column) => 'Resize $column';

/// A list of 50 000 rows must build only what is on screen and scroll without
/// dropping frames. The budgets are loose: the test runs in a debug VM with
/// software rendering, much slower than a release build.
void main() {
  testWidgets('50 000 cards open fast and scrolling stays within budget', (
    tester,
  ) async {
    final built = <int>{};
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final open = Stopwatch()..start();
    await pumpKit(
      tester,
      SizedBox(
        width: 800,
        height: 600,
        child: DlmDataTable<int>(
          semanticLabel: 'Rows',
          labels: const DlmTableLabels(
            sortedAscending: 'asc',
            sortedDescending: 'desc',
            resizeColumn: _resize,
            loadingRow: 'loading',
          ),
          columns: const [],
          itemCount: 50000,
          itemAt: (i) => i,
          rowId: (r) => r,
          rowSemanticLabel: (r) => 'row $r',
          scrollController: controller,
          rowExtent: 100,
          rowBuilder: (_, row, states) {
            built.add(row);
            return SizedBox(height: 100, child: Text('card $row'));
          },
        ),
      ),
    );
    open.stop();
    expect(
      open.elapsedMilliseconds,
      lessThan(3000),
      reason: 'first frame of 50 000 rows: ${open.elapsedMilliseconds} ms',
    );
    expect(built.length, lessThan(30), reason: 'only the visible rows build');

    final frames = <int>[];
    for (var i = 0; i < 60; i++) {
      controller.jumpTo(controller.offset + 1237);
      final w = Stopwatch()..start();
      await tester.pump();
      w.stop();
      frames.add(w.elapsedMicroseconds);
    }
    frames.sort();
    final p95 = frames[(frames.length * 0.95).floor()] / 1000;
    expect(p95, lessThan(100), reason: 'p95 frame $p95 ms (budget 100 ms)');
    expect(built.length, lessThan(2500), reason: 'rows built while scrolling');
  });
}
