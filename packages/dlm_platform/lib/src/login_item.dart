import 'dart:io';

import 'package:flutter/services.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

/// The argument a login item starts the app with. The plan names it
/// `--minimised`: the app was started by the system and may keep its window
/// hidden. macOS cannot pass arguments through `SMAppService`, so there the
/// launch event is read as well.
const String minimisedFlag = '--minimised';

/// Whether the app starts when the user logs in.
abstract interface class LoginItem {
  /// Whether the entry exists.
  Future<bool> isEnabled();

  /// Adds or removes the entry.
  Future<void> setEnabled({required bool enabled});

  /// Whether this process was started by the system at login; [args] are the
  /// command-line arguments of `main`.
  Future<bool> startedAtLogin(List<String> args);
}

/// No login item on this platform or build: always off, cannot be turned on.
class UnsupportedLoginItem implements LoginItem {
  /// Creates the no-op item.
  const UnsupportedLoginItem();

  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<bool> startedAtLogin(List<String> args) async => false;
}

/// Thrown when the system refuses to change the login item.
class LoginItemException implements Exception {
  /// Creates the exception.
  const LoginItemException(this.message);

  /// What went wrong.
  final String message;

  @override
  String toString() => 'LoginItemException($message)';
}

/// Linux: an XDG autostart entry in `$XDG_CONFIG_HOME/autostart`.
class XdgAutostartLoginItem implements LoginItem {
  /// Creates the item. The arguments exist for tests.
  XdgAutostartLoginItem({
    this.appId = 'io.github.sabadia.dlm',
    this.name = 'dlm',
    String? executable,
    Map<String, String>? environment,
  }) : _executable = executable ?? Platform.resolvedExecutable,
       _environment = environment ?? Platform.environment;

  /// The desktop-entry id, used as the file name.
  final String appId;

  /// The name the desktop shows.
  final String name;

  final String _executable;
  final Map<String, String> _environment;

  static bool _absolute(String path) =>
      path.startsWith('/') ||
      path.startsWith(r'\') ||
      (path.length >= 3 && path[1] == ':');

  /// The autostart entry.
  File get file {
    final xdg = _environment['XDG_CONFIG_HOME'];
    final home = _environment['HOME'];
    // An absolute path counts on every system. A Windows temp directory is
    // `C:\...`, and these tests run there too.
    final base = xdg != null && _absolute(xdg)
        ? xdg
        : home == null
        ? throw const LoginItemException(r'$HOME is not set')
        : '$home/.config';
    return File('$base/autostart/$appId.desktop');
  }

  /// The text of the entry. Spaces and quotes in the path are escaped as the
  /// Desktop Entry specification asks.
  String get content {
    final exec = _executable.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '[Desktop Entry]\n'
        'Type=Application\n'
        'Name=$name\n'
        'Exec="$exec" $minimisedFlag\n'
        'X-GNOME-Autostart-enabled=true\n'
        'Terminal=false\n';
  }

  @override
  Future<bool> isEnabled() async => file.existsSync();

  @override
  Future<void> setEnabled({required bool enabled}) async {
    final f = file;
    if (!enabled) {
      if (f.existsSync()) await f.delete();
      return;
    }
    await f.parent.create(recursive: true);
    await f.writeAsString(content);
  }

  @override
  Future<bool> startedAtLogin(List<String> args) async =>
      args.contains(minimisedFlag);
}

/// Linux inside Flatpak: the sandbox cannot write the autostart file, so the
/// Background portal does it. The portal cannot be asked, so the answer of the
/// last request is kept in [marker].
class PortalLoginItem implements LoginItem {
  /// Creates the item; [marker] remembers the last answer.
  PortalLoginItem({required this.marker, this.commandLine = const []});

  /// A file that exists while the autostart is on.
  final File marker;

  /// The command the portal starts.
  final List<String> commandLine;

  @override
  Future<bool> isEnabled() async => marker.existsSync();

  @override
  Future<void> setEnabled({required bool enabled}) async {
    final client = XdgDesktopPortalClient();
    try {
      final result = await client.background
          .requestBackground(
            autostart: enabled,
            commandLine: [...commandLine, minimisedFlag],
          )
          .first;
      if (result.autostart != enabled) {
        throw const LoginItemException('The system did not allow it.');
      }
    } finally {
      await client.close();
    }
    if (enabled) {
      await marker.parent.create(recursive: true);
      await marker.writeAsString('');
    } else if (marker.existsSync()) {
      await marker.delete();
    }
  }

  @override
  Future<bool> startedAtLogin(List<String> args) async =>
      args.contains(minimisedFlag);
}

/// Reads and writes values of the current user's `Run` key, behind an
/// interface so [RegistryLoginItem] is tested without Windows.
abstract interface class RunKey {
  /// The command stored under [name], or null.
  String? read(String name);

  /// Stores [command] under [name].
  void write(String name, String command);

  /// Removes [name]; no error when it is not there.
  void delete(String name);
}

/// [RunKey] over the registry (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`).
class Win32RunKey implements RunKey {
  /// Creates the access.
  const Win32RunKey();

  static const _path = r'Software\Microsoft\Windows\CurrentVersion\Run';

  T _with<T>(T Function(RegistryKey key) body) {
    final root = RegistryKey.openCurrentUser(RegistryAccess.readWrite);
    RegistryKey? key;
    try {
      key = root.create(_path);
      return body(key);
    } on Object catch (e) {
      // Every failure of the registry API is a refusal of the system.
      throw LoginItemException(e.toString());
    } finally {
      key?.close();
      root.close();
    }
  }

  @override
  String? read(String name) {
    try {
      return _with((k) => k.getString(name));
    } on LoginItemException {
      return null;
    }
  }

  @override
  void write(String name, String command) =>
      _with((k) => k.setValue(name, RegistryValue.string(command)));

  @override
  void delete(String name) {
    final key = RegistryKey.openCurrentUser(RegistryAccess.readWrite);
    RegistryKey? run;
    try {
      run = key.open(
        _path,
        config: const RegistryOpenConfig(access: RegistryAccess.readWrite),
      )..removeValue(name);
    } on Object {
      // A missing key or value: nothing to remove.
    } finally {
      run?.close();
      key.close();
    }
  }
}

/// Windows: a value in the user's `Run` key.
class RegistryLoginItem implements LoginItem {
  /// Creates the item. The arguments exist for tests.
  RegistryLoginItem({
    RunKey run = const Win32RunKey(),
    this.name = 'dlm',
    String? executable,
  }) : _run = run,
       _executable = executable ?? Platform.resolvedExecutable;

  /// The value name.
  final String name;

  final RunKey _run;
  final String _executable;

  /// The command the system runs at login.
  String get command => '"$_executable" $minimisedFlag';

  @override
  Future<bool> isEnabled() async => _run.read(name) != null;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    if (enabled) {
      _run.write(name, command);
    } else {
      _run.delete(name);
    }
  }

  @override
  Future<bool> startedAtLogin(List<String> args) async =>
      args.contains(minimisedFlag);
}

/// macOS: `SMAppService.mainApp` in `DlmPlatformPlugin` (Swift). The system
/// cannot pass arguments to it, so whether the app was started at login comes
/// from the launch event.
class MethodChannelLoginItem implements LoginItem {
  /// Creates the item; tests pass their own [channel].
  MethodChannelLoginItem({
    MethodChannel channel = const MethodChannel('dlm/login_item'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<bool> isEnabled() async =>
      await _channel.invokeMethod<bool>('isEnabled') ?? false;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    try {
      await _channel.invokeMethod<void>('setEnabled', {'enabled': enabled});
    } on PlatformException catch (e) {
      throw LoginItemException(e.message ?? e.code);
    }
  }

  @override
  Future<bool> startedAtLogin(List<String> args) async =>
      args.contains(minimisedFlag) ||
      (await _channel.invokeMethod<bool>('startedAtLogin') ?? false);
}

/// The login item of this operating system.
LoginItem platformLoginItem({File? flatpakMarker}) {
  if (Platform.isMacOS) return MethodChannelLoginItem();
  if (Platform.isWindows) return RegistryLoginItem();
  if (Platform.isLinux) {
    return Platform.environment.containsKey('FLATPAK_ID') &&
            flatpakMarker != null
        ? PortalLoginItem(marker: flatpakMarker, commandLine: const ['dlm'])
        : XdgAutostartLoginItem();
  }
  return const UnsupportedLoginItem();
}
