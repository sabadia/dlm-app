import 'package:intl/intl.dart';

/// How byte counts are written.
enum UnitSystem {
  /// 1 KiB = 1024 B (KiB, MiB, GiB), what file managers of most systems and
  /// the command line show.
  iec,

  /// 1 kB = 1000 B (kB, MB, GB), what disk makers and macOS Finder show.
  si,
}

const _iecUnits = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB'];
const _siUnits = ['B', 'kB', 'MB', 'GB', 'TB', 'PB'];

/// Writes [bytes] as `1.50 MiB`; null for a negative count, which the daemon
/// uses for "unknown". Fewer decimals as the number grows (`1.50`, `15.0`,
/// `150`), digits and decimal separator follow [locale].
String? formatBytes(
  int bytes, {
  UnitSystem system = UnitSystem.iec,
  String? locale,
}) {
  if (bytes < 0) return null;
  final base = system == UnitSystem.iec ? 1024 : 1000;
  final units = system == UnitSystem.iec ? _iecUnits : _siUnits;
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= base && unit < units.length - 1) {
    value /= base;
    unit++;
  }
  if (unit == 0) return '$bytes ${units[0]}';
  // 1023.96 KiB would print as "1024 KiB": move up a unit instead.
  if (_rounded(value) >= base && unit < units.length - 1) {
    value /= base;
    unit++;
  }
  final digits = value >= 100 ? 0 : (value >= 10 ? 1 : 2);
  final text = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: digits,
  ).format(value);
  return '$text ${units[unit]}';
}

double _rounded(double v) {
  final digits = v >= 100 ? 0 : (v >= 10 ? 1 : 2);
  return double.parse(v.toStringAsFixed(digits));
}

/// Writes a transfer rate, `1.50 MiB/s`; null when unknown (negative).
String? formatSpeed(
  int bytesPerSecond, {
  UnitSystem system = UnitSystem.iec,
  String? locale,
}) {
  final text = formatBytes(bytesPerSecond, system: system, locale: locale);
  return text == null ? null : '$text/s';
}

const _suffixes = <String, double>{
  '': 1,
  'B': 1,
  'K': 1024,
  'KB': 1e3,
  'KIB': 1024,
  'M': 1048576,
  'MB': 1e6,
  'MIB': 1048576,
  'G': 1073741824,
  'GB': 1e9,
  'GIB': 1073741824,
  'T': 1099511627776,
  'TB': 1e12,
  'TIB': 1099511627776,
  'P': 1125899906842624,
  'PB': 1e15,
  'PIB': 1125899906842624,
};

/// Reads a size a person typed: `512`, `512K`, `1.5MB`, `2 MiB`, `1,5 GB`.
///
/// The same rules as the `dlm` command line: a bare letter (K, M, G) counts
/// 1024, `KB`/`MB`/`GB` count 1000, `KiB`/`MiB`/`GiB` count 1024. Fractions are
/// rounded down to whole bytes. A comma is a decimal separator when no dot is
/// present. Returns null for anything else (so a form can flag it).
int? parseSize(String input) {
  final text = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  final m = RegExp(r'^(\d+(?:[.,]\d+)?|[.,]\d+)\s*([A-Za-z]*)$')
      .firstMatch(text);
  if (m == null) return null;
  final multiplier = _suffixes[m.group(2)!.toUpperCase()];
  if (multiplier == null) return null;
  final value = double.tryParse(m.group(1)!.replaceFirst(',', '.'));
  if (value == null) return null;
  final bytes = (value * multiplier).floorToDouble();
  if (bytes >= 9007199254740992) return null; // beyond exact doubles
  return bytes.toInt();
}
