import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

void main() {
  group('formatBytes', () {
    test('IEC units with fewer decimals as numbers grow', () {
      for (final (bytes, text) in [
        (0, '0 B'),
        (999, '999 B'),
        (1024, '1.00 KiB'),
        (1536, '1.50 KiB'),
        (10 * 1024, '10.0 KiB'),
        (150 * 1024, '150 KiB'),
        (1048576, '1.00 MiB'),
        (5 * 1073741824, '5.00 GiB'),
        (3 * 1099511627776, '3.00 TiB'),
      ]) {
        expect(formatBytes(bytes), text, reason: '$bytes');
      }
    });

    test('SI units', () {
      expect(formatBytes(1000, system: UnitSystem.si), '1.00 kB');
      expect(formatBytes(1500000, system: UnitSystem.si), '1.50 MB');
      expect(formatBytes(999, system: UnitSystem.si), '999 B');
    });

    test('a value that rounds up to the next unit moves up', () {
      expect(formatBytes(1048575), '1.00 MiB', reason: 'not 1024 KiB');
    });

    test(
      'unknown sizes are null, and the decimal separator follows the locale',
      () {
        expect(formatBytes(-1), isNull);
        expect(formatBytes(1536, locale: 'de'), '1,50 KiB');
        expect(formatBytes(1536), '1.50 KiB');
      },
    );

    test('speed appends /s', () {
      expect(formatSpeed(2 * 1048576), '2.00 MiB/s');
      expect(formatSpeed(-1), isNull);
    });
  });

  group('parseSize', () {
    test('matches the command line', () {
      for (final (text, bytes) in [
        ('0', 0),
        ('512', 512),
        ('512K', 524288),
        ('1MB', 1000000),
        ('1 MiB', 1048576),
        ('2M', 2097152),
        ('1.5GB', 1500000000),
        ('1.5GiB', 1610612736),
        ('  10  kb ', 10000),
        ('.5K', 512),
        ('1PiB', 1125899906842624),
      ]) {
        expect(parseSize(text), bytes, reason: text);
      }
    });

    test('a comma is a decimal separator', () {
      expect(parseSize('1,5 GB'), 1500000000);
    });

    test('garbage is null', () {
      for (final bad in ['', 'abc', '1.2.3', '5 furlongs', '-1', 'MB', '1e3']) {
        expect(parseSize(bad), isNull, reason: bad);
      }
    });

    test('what is written can be read back', () {
      for (final bytes in [0, 1, 1023, 1024, 123456, 5 * 1073741824]) {
        final text = formatBytes(bytes)!;
        final back = parseSize(text.replaceAll('KiB', 'KiB'));
        // The text is rounded for people; reading it gives a nearby value.
        expect(
          (back! - bytes).abs() <= bytes * 0.01 + 1,
          isTrue,
          reason: '$bytes -> $text -> $back',
        );
      }
    });
  });

  group('durations', () {
    test('format with at most two units', () {
      for (final (d, text) in [
        (Duration.zero, '< 1 s'),
        (const Duration(milliseconds: 900), '< 1 s'),
        (const Duration(seconds: 45), '45 s'),
        (const Duration(minutes: 3, seconds: 5), '3 min 5 s'),
        (const Duration(minutes: 12, seconds: 5), '12 min'),
        (const Duration(hours: 1, minutes: 5, seconds: 9), '1 h 5 min'),
        (const Duration(hours: 2), '2 h'),
        (const Duration(days: 2, hours: 3, minutes: 1), '2 d 3 h'),
        (const Duration(days: 4), '4 d'),
      ]) {
        expect(formatDuration(d), text, reason: '$d');
      }
    });

    test('eta is null while unknown', () {
      expect(formatEta(null), isNull);
      expect(formatEta(0), isNull);
      expect(formatEta(-1), isNull);
      expect(formatEta(90), '1 min 30 s');
    });

    test('remaining time from progress', () {
      expect(
        estimateRemaining(downloaded: 50, size: 150, bytesPerSecond: 10),
        const Duration(seconds: 10),
      );
      expect(
        estimateRemaining(downloaded: 1, size: -1, bytesPerSecond: 10),
        isNull,
      );
      expect(
        estimateRemaining(downloaded: 1, size: 10, bytesPerSecond: 0),
        isNull,
      );
      expect(
        estimateRemaining(downloaded: 10, size: 10, bytesPerSecond: 5),
        isNull,
      );
    });

    test('parse what people type', () {
      for (final (text, d) in [
        ('90', const Duration(seconds: 90)),
        ('90s', const Duration(seconds: 90)),
        ('1h30m', const Duration(hours: 1, minutes: 30)),
        ('1h 30 min', const Duration(hours: 1, minutes: 30)),
        ('2d', const Duration(days: 2)),
        (
          '1d 2h 3m 4s',
          const Duration(days: 1, hours: 2, minutes: 3, seconds: 4),
        ),
        ('1:30:00', const Duration(hours: 1, minutes: 30)),
        ('5:00', const Duration(minutes: 5)),
      ]) {
        expect(parseDuration(text), d, reason: text);
      }
      for (final bad in ['', 'soon', '1x', '1:75', '12:99:00', '1h junk']) {
        expect(parseDuration(bad), isNull, reason: bad);
      }
    });
  });

  group('relativeTime', () {
    final now = DateTime(2026, 10, 29, 15);
    test('classifies the age', () {
      expect(
        relativeTime(now.subtract(const Duration(seconds: 20)), now),
        const RelativeTime(RelativeKind.justNow),
      );
      expect(
        relativeTime(now.subtract(const Duration(minutes: 5)), now),
        const RelativeTime(RelativeKind.minutes, 5),
      );
      expect(
        relativeTime(DateTime(2026, 10, 29, 12), now),
        const RelativeTime(RelativeKind.hours, 3),
      );
      expect(
        relativeTime(DateTime(2026, 10, 28, 23), now),
        const RelativeTime(RelativeKind.yesterday),
      );
      expect(
        relativeTime(DateTime(2026, 10, 26, 9), now),
        const RelativeTime(RelativeKind.days, 3),
      );
      expect(
        relativeTime(DateTime(2026, 10), now),
        const RelativeTime(RelativeKind.date),
      );
    });

    test('a time in the future is just now', () {
      expect(
        relativeTime(now.add(const Duration(minutes: 2)), now),
        const RelativeTime(RelativeKind.justNow),
      );
    });
  });
}
