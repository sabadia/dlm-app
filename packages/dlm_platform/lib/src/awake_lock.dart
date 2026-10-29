import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';

/// Keeps the computer from sleeping while downloads are running, and lets it
/// sleep again when they are not.
abstract interface class AwakeLock {
  /// Holds sleep off while [awake] is true.
  Future<void> setAwake({required bool awake});
}

/// Does not touch power management.
class UnsupportedAwakeLock implements AwakeLock {
  /// Creates the no-op lock.
  const UnsupportedAwakeLock();

  @override
  Future<void> setAwake({required bool awake}) async {}
}

/// The lock for this operating system.
///
/// macOS uses `ProcessInfo` so the display may still sleep. Windows uses
/// `SetThreadExecutionState`. Linux runs `systemd-inhibit` when it exists
/// (it does not, inside some sandboxes, and then this does nothing).
class PlatformAwakeLock implements AwakeLock {
  /// Creates the lock. [channel] exists for tests of the macOS call.
  PlatformAwakeLock({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('dlm/awake');

  final MethodChannel _channel;
  var _awake = false;
  Process? _inhibit;

  @override
  Future<void> setAwake({required bool awake}) async {
    if (_awake == awake) return;
    _awake = awake;
    if (Platform.isMacOS) {
      try {
        await _channel.invokeMethod<void>('set', {'awake': awake});
      } on MissingPluginException {
        // The embedder has no power channel.
      }
      return;
    }
    if (Platform.isWindows) {
      _keepWindowsAwake(awake);
      return;
    }
    await _keepLinuxAwake(awake);
  }

  Future<void> _keepLinuxAwake(bool awake) async {
    if (!awake) {
      _inhibit?.kill();
      _inhibit = null;
      return;
    }
    try {
      _inhibit = await Process.start('systemd-inhibit', const [
        '--what=idle:sleep',
        '--who=dlm',
        '--why=Downloading',
        '--mode=block',
        'sleep',
        'infinity',
      ]);
    } on ProcessException {
      _inhibit = null;
    }
  }
}

int Function(int)? _windowsExecutionState;

/// `ES_CONTINUOUS`. Clearing the other flags still needs this one.
const int _esContinuous = 0x80000000;

/// `ES_SYSTEM_REQUIRED`: the system stays awake. The display may sleep.
const int _esSystemRequired = 0x00000001;

void _keepWindowsAwake(bool awake) {
  final set = _windowsExecutionState ??= DynamicLibrary.open('kernel32.dll')
      .lookupFunction<Uint32 Function(Uint32), int Function(int)>(
        'SetThreadExecutionState',
      );
  set(awake ? _esContinuous | _esSystemRequired : _esContinuous);
}
