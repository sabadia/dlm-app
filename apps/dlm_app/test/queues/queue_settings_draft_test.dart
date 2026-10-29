import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/queues/queue_settings_draft.dart';
import 'package:flutter_test/flutter_test.dart';

TimeWindow w(List<String> days, String start, String end) =>
    TimeWindow(days: days, start: start, end: end);

void main() {
  group('go durations', () {
    test('are written the way the daemon reads them', () {
      expect(goDuration(const Duration(hours: 24)), '24h0m0s');
      expect(goDuration(const Duration(minutes: 90)), '1h30m0s');
      expect(goDuration(const Duration(minutes: 1)), '1m0s');
      expect(goDuration(const Duration(seconds: 45)), '45s');
    });

    test('are read back', () {
      expect(parseGoDuration('24h0m0s'), const Duration(hours: 24));
      expect(parseGoDuration('1m0s'), const Duration(minutes: 1));
      expect(parseGoDuration('1.5s'), const Duration(milliseconds: 1500));
      expect(parseGoDuration('soon'), isNull);
      expect(parseGoDuration(null), isNull);
    });
  });

  group('windows and the grid', () {
    test('a window fills the cells of its hours on its days', () {
      final d = WindowsDraft.from(null, [
        w(['mon', 'tue'], '01:00', '04:00'),
      ]);
      expect(d.exact, isTrue);
      expect(d.cells, {1, 2, 3, 25, 26, 27});
    });

    test('a window across midnight continues on the next day', () {
      final d = WindowsDraft.from(null, [
        w(['sun'], '22:00', '02:00'),
      ]);
      expect(d.cells, {6 * 24 + 22, 6 * 24 + 23, 0, 1});
    });

    test('minutes cannot be shown, so the windows are kept as they are', () {
      final windows = [
        w(['mon'], '09:30', '10:00'),
      ];
      final d = WindowsDraft.from('Europe/Berlin', windows);
      expect(d.exact, isFalse);
      expect(d.toWindows().single.start, '09:30');
      d.useGrid(windows);
      expect(d.exact, isTrue);
      expect(d.cells, {9}, reason: 'every touched hour counts');
    });

    test('cells become one window per run, days with equal runs share it', () {
      final d = WindowsDraft(
        cells: {1, 2, 24 + 1, 24 + 2, 24 * 2 + 22, 24 * 2 + 23},
      );
      final out = d.toWindows();
      expect(out.map((e) => '${e.days}${e.start}-${e.end}'), [
        '[mon, tue]01:00-03:00',
        '[wed]22:00-00:00',
      ]);
    });

    test('a run to midnight ends at 00:00 and reads back the same', () {
      final cells = {22, 23};
      final back = WindowsDraft.from(
        null,
        WindowsDraft(cells: cells).toWindows(),
      );
      expect(back.cells, cells);
    });

    test('a whole day is two windows, never an equal start and end', () {
      final cells = {for (var h = 0; h < 24; h++) 24 + h};
      final out = WindowsDraft(cells: cells).toWindows();
      expect(out, hasLength(2));
      expect(out.every((e) => e.start != e.end), isTrue);
      expect(WindowsDraft.from(null, out).cells, cells);
    });

    test('round trip of an arbitrary week', () {
      final cells = {0, 5, 6, 47, 48, 100, 101, 167};
      expect(
        WindowsDraft.from(null, WindowsDraft(cells: cells).toWindows()).cells,
        cells,
      );
    });
  });

  group('settings', () {
    test('reading an empty override gives "no override"', () {
      final d = QueueSettingsDraft.from(const Settings());
      expect(d.scheduleOn, isFalse);
      expect(d.quotaOn, isFalse);
      expect(d.finish, QueueFinish.none);
      expect(d.profiles, isEmpty);
      expect(d.speedLimit, isNull);
      expect(d.valid, isTrue);
    });

    test('everything edited is written, the rest is carried over', () {
      final d = QueueSettingsDraft(
        speedLimit: 2000000,
        scheduleOn: true,
        schedule: WindowsDraft(cells: {1, 2}, timezone: 'UTC'),
        profiles: [
          ProfileDraft(windows: WindowsDraft(cells: {10}), speedLimit: 500000),
        ],
        quotaOn: true,
        quotaBytes: 1000,
        quotaPeriod: const Duration(hours: 24),
        finish: QueueFinish.command,
        finishDelay: const Duration(minutes: 2),
        command: '/usr/bin/notify',
        args: ['done'],
      );
      final out = d.applyTo(
        const Settings(downloadDir: '/data', maxConnections: 4),
      );
      final json = out.toJson();
      expect(out.downloadDir, '/data');
      expect(out.maxConnections, 4);
      expect(out.speedLimit, 2000000);
      expect(out.schedule!.timezone, 'UTC');
      expect(out.schedule!.windows!.single.start, '01:00');
      expect(json['quota'], {'bytes': 1000, 'period': '24h0m0s'});
      expect(json['onQueueComplete'], {
        'action': 'command',
        'command': '/usr/bin/notify',
        'args': ['done'],
        'delay': '2m0s',
      });
      expect(
        (json['speedProfiles']! as List).single,
        containsPair('speedLimit', 500000),
      );

      final again = QueueSettingsDraft.from(out);
      expect(again.scheduleOn, isTrue);
      expect(again.schedule.cells, {1, 2});
      expect(again.quotaBytes, 1000);
      expect(again.quotaPeriod, const Duration(hours: 24));
      expect(again.finish, QueueFinish.command);
      expect(again.finishDelay, const Duration(minutes: 2));
      expect(again.args, ['done']);
      expect(again.profiles.single.speedLimit, 500000);
      expect(again.profiles.single.windows.cells, {10});
    });

    test('switching an override off unsets it', () {
      final base = QueueSettingsDraft(
        speedLimit: 1,
        scheduleOn: true,
        schedule: WindowsDraft(cells: {1}),
        quotaOn: true,
        quotaBytes: 5,
        quotaPeriod: const Duration(hours: 1),
        finish: QueueFinish.stop,
      ).applyTo(const Settings());
      final cleared = QueueSettingsDraft.from(base)
        ..speedLimit = null
        ..scheduleOn = false
        ..quotaOn = false
        ..finish = QueueFinish.none;
      final out = cleared.applyTo(base).toJson();
      expect(out['speedLimit'], isNull);
      expect(out['schedule'], isNull);
      expect(out['quota'], isNull);
      expect(out['onQueueComplete'], isNull);
    });

    test('what the daemon would refuse is not valid', () {
      expect(QueueSettingsDraft(scheduleOn: true).valid, isFalse);
      expect(
        QueueSettingsDraft(profiles: [ProfileDraft(windows: WindowsDraft())])
            .valid,
        isFalse,
      );
      expect(QueueSettingsDraft(quotaOn: true, quotaBytes: 5).valid, isFalse);
      expect(
        QueueSettingsDraft(
          quotaOn: true,
          quotaBytes: 5,
          quotaPeriod: const Duration(seconds: 30),
        ).valid,
        isFalse,
      );
      expect(
        QueueSettingsDraft(finishDelay: const Duration(hours: 25)).valid,
        isFalse,
      );
      expect(
        QueueSettingsDraft(
          finish: QueueFinish.command,
          command: 'notify',
        ).valid,
        isFalse,
      );
      expect(
        QueueSettingsDraft(
          finish: QueueFinish.command,
          command: r'C:\Tools\n.exe',
        ).valid,
        isTrue,
      );
    });
  });
}
