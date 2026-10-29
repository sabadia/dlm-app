import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/statistics_screen.dart';
import 'package:dlm_app/src/manage/timeline_series.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

/// Traffic and cleanup in memory.
class FakeStats implements StatsRepository {
  FakeStats(this.timelineFor, {this.matched = 3});

  final Timeline Function(Bucket, GroupBy) timelineFor;
  final int matched;
  final List<String> calls = [];

  @override
  Future<Timeline> timeline(Bucket bucket, GroupBy groupBy) async {
    calls.add('timeline ${bucket.json} ${groupBy.json}');
    return timelineFor(bucket, groupBy);
  }

  @override
  Future<CleanupResult> cleanup({
    required int olderThanDays,
    bool files = false,
    bool dryRun = false,
    String? queueId,
  }) async {
    calls.add('cleanup $olderThanDays $files $dryRun');
    return CleanupResult(
      bytes: 1536,
      deleted: dryRun ? 0 : matched,
      failed: 0,
      matched: matched,
    );
  }
}

Timeline _timeline(Bucket b, GroupBy g) => Timeline(
  bucket: b.json ?? '',
  from: DateTime.utc(2026, 5, 4),
  groupBy: g.json ?? '',
  to: DateTime.utc(2026, 5, 5),
  points: [
    TimelinePoint(
      down: 1000,
      up: 10,
      time: DateTime.utc(2026, 5, 4, 10),
      group: g == GroupBy.none ? null : 'http',
    ),
    TimelinePoint(
      down: 3000,
      up: 20,
      time: DateTime.utc(2026, 5, 4, 10),
      group: g == GroupBy.none ? null : 'bt',
    ),
    TimelinePoint(
      down: 500,
      up: 0,
      time: DateTime.utc(2026, 5, 4, 11),
      group: g == GroupBy.none ? null : 'http',
    ),
  ],
);

const _stats = StatsBody(
  completed: [],
  byStatus: {'completed': 4, 'running': 1},
  downloadedBytes: 5 * 1024 * 1024,
  tasks: 5,
  byEngine: [EngineStatsBody(downloadedBytes: 1024, engine: 'http', tasks: 3)],
);

void main() {
  group('series', () {
    test('buckets are in time order and stack by group', () {
      final s = TimelineSeries.of(_timeline(Bucket.hour, GroupBy.engine));
      expect(s.times, [
        DateTime.utc(2026, 5, 4, 10),
        DateTime.utc(2026, 5, 4, 11),
      ]);
      expect(s.groups, ['bt', 'http']);
      expect(s.downIn(0), 4000);
      expect(s.downIn(1), 500);
      expect(s.totalDown, 4500);
      expect(s.totalUp, 30);
      expect(s.peakDown, 4000);
      expect(s.isEmpty, isFalse);
    });

    test('an unsplit timeline has one unnamed group', () {
      final s = TimelineSeries.of(_timeline(Bucket.day, GroupBy.none));
      expect(s.groups, ['']);
      expect(s.totalDown, 4500);
    });

    test('no points means no traffic', () {
      final s = TimelineSeries.of(
        Timeline(
          bucket: 'hour',
          from: DateTime.utc(2026),
          groupBy: 'none',
          points: const [],
          to: DateTime.utc(2026),
        ),
      );
      expect(s.isEmpty, isTrue);
      expect(s.peakDown, 0);
    });
  });

  Future<AppHarness> open(
    WidgetTester tester,
    FakeStats stats, {
    List<Task> tasks = const [],
  }) async {
    final h = await pumpApp(
      tester,
      tasks: tasks,
      overrides: [
        statsRepositoryProvider.overrideWithValue(stats),
        statsProvider.overrideWith((ref) async => _stats),
      ],
    );
    h.container.read(routerProvider).go('/manage/statistics');
    await settle(tester);
    return h;
  }

  Finder pageScroll() => find
      .descendant(
        of: find.byType(StatisticsScreen),
        matching: find.byType(Scrollable),
      )
      .first;

  appTest('totals, state and engines are shown', (tester) async {
    await open(tester, FakeStats(_timeline));
    expect(find.text('5'), findsWidgets);
    expect(find.text('5.00 MiB'), findsOneWidget);
    expect(find.text('completed: 4'), findsOneWidget);
    expect(find.text('http: 3 · 1.00 KiB'), findsOneWidget);
  });

  appTest('the chart follows the bucket and the split', (tester) async {
    final stats = FakeStats(_timeline);
    await open(tester, stats);
    expect(stats.calls.last, 'timeline hour none');
    Future<void> pick(String label, String option) async {
      final d = find.byWidgetPredicate(
        (w) => w is DlmDropdown && w.semanticLabel == label,
      );
      await tester.ensureVisible(d);
      await tester.tap(d);
      await settle(tester);
      await tester.tap(find.text(option).last);
      await settle(tester);
    }

    await pick('Split by', 'Engine');
    expect(stats.calls.last, 'timeline hour engine');
    expect(find.text('http'), findsWidgets);
    expect(find.text('bt'), findsWidgets);
    await pick('Bucket', 'Per day');
    expect(stats.calls.last, 'timeline day engine');
  });

  appTest('finished downloads are listed and can be searched', (tester) async {
    await open(
      tester,
      FakeStats(_timeline),
      tasks: [
        task('a', status: 'completed', name: 'ubuntu.iso', downloaded: 100),
        task('b', status: 'completed', name: 'movie.mkv', downloaded: 100),
        task('c', status: 'running', name: 'still-going.zip'),
      ],
    );
    await tester.scrollUntilVisible(
      find.text('ubuntu.iso'),
      300,
      scrollable: pageScroll(),
    );
    expect(find.text('ubuntu.iso'), findsOneWidget);
    expect(find.text('movie.mkv'), findsOneWidget);
    expect(find.text('still-going.zip'), findsNothing);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(StatisticsScreen),
            matching: find.byType(EditableText),
          )
          .first,
      'movie',
    );
    await tester.pump(const Duration(milliseconds: 100));
    await settle(tester);
    expect(find.text('ubuntu.iso'), findsNothing);
    expect(find.text('movie.mkv'), findsOneWidget);
  });

  appTest('cleanup is previewed, then confirmed', (tester) async {
    final stats = FakeStats(_timeline);
    await open(tester, stats);
    await tester.scrollUntilVisible(
      find.text('Check what would go'),
      300,
      scrollable: pageScroll(),
    );
    await tester.tap(find.text('Check what would go'));
    await settle(tester);
    expect(stats.calls.last, 'cleanup 30 false true');
    expect(
      find.text('3 downloads (1.50 KiB) would be removed.'),
      findsOneWidget,
    );
    await tester.drag(pageScroll(), const Offset(0, -400));
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Clean up'));
    await settle(tester);
    expect(find.text('Remove 3 downloads?'), findsOneWidget);
    expect(
      find.text('They leave the list; the files stay where they are.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Clean up').last);
    await settle(tester);
    // The chart is read again afterwards, so the cleanup is not the last call.
    expect(stats.calls, contains('cleanup 30 false false'));
    expect(find.text('Removed 3 downloads'), findsOneWidget);
  });

  appTest('deleting the files is said plainly before it happens', (
    tester,
  ) async {
    final stats = FakeStats(_timeline);
    await open(tester, stats);
    await tester.scrollUntilVisible(
      find.text('Check what would go'),
      300,
      scrollable: pageScroll(),
    );
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmSwitch && w.semanticLabel == 'Also delete the files',
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Check what would go'));
    await settle(tester);
    expect(stats.calls.last, 'cleanup 30 true true');
    await tester.drag(pageScroll(), const Offset(0, -400));
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Clean up'));
    await settle(tester);
    expect(
      find.textContaining('files are deleted from the disk'),
      findsOneWidget,
    );
  });

  appTest('nothing to clean up offers no button', (tester) async {
    await open(tester, FakeStats(_timeline, matched: 0));
    await tester.scrollUntilVisible(
      find.text('Check what would go'),
      300,
      scrollable: pageScroll(),
    );
    await tester.tap(find.text('Check what would go'));
    await settle(tester);
    expect(find.widgetWithText(DlmButton, 'Clean up'), findsNothing);
  });
}
