import 'dart:async';

import 'package:tray_manager/tray_manager.dart';

/// One line of the tray menu.
class TrayEntry {
  /// A clickable line; [id] comes back through [TrayController.selections].
  const TrayEntry(this.id, this.label, {this.enabled = true})
    : separator = false;

  /// A dividing line.
  const TrayEntry.separator()
    : id = '',
      label = '',
      enabled = false,
      separator = true;

  /// What identifies the line when it is chosen.
  final String id;

  /// The text.
  final String label;

  /// Whether it can be chosen.
  final bool enabled;

  /// Whether this is a divider.
  final bool separator;

  @override
  bool operator ==(Object other) =>
      other is TrayEntry &&
      other.id == id &&
      other.label == label &&
      other.enabled == enabled &&
      other.separator == separator;

  @override
  int get hashCode => Object.hash(id, label, enabled, separator);
}

/// The icon in the menu bar or notification area, with a title (macOS only,
/// next to the icon), a tooltip and a menu.
abstract interface class TrayController {
  /// Whether this system can show a tray icon at all.
  bool get supported;

  /// Whether the icon is showing now.
  bool get visible;

  /// The ids of the menu lines the user chooses.
  Stream<String> get selections;

  /// Shows the icon with the given [menu], [tooltip] and [title].
  Future<void> show({
    required String iconAsset,
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  });

  /// Changes what is showing without recreating the icon.
  Future<void> update({
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  });

  /// Removes the icon.
  Future<void> hide();
}

/// No tray: nothing shows, and the app treats closing the window as quitting.
class UnsupportedTray implements TrayController {
  /// Creates the no-op tray.
  const UnsupportedTray();

  @override
  bool get supported => false;

  @override
  bool get visible => false;

  @override
  Stream<String> get selections => const Stream.empty();

  @override
  Future<void> show({
    required String iconAsset,
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  }) async {}

  @override
  Future<void> update({
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  }) async {}

  @override
  Future<void> hide() async {}
}

/// [TrayController] over `tray_manager`'s native API.
class TrayManagerController implements TrayController {
  /// Creates the controller; the icon is made on [show].
  TrayManagerController();

  TrayIcon? _icon;
  Menu? _menu;
  final List<MenuItem> _items = [];
  final StreamController<String> _selections = StreamController.broadcast();

  @override
  bool get supported => TrayManager.instance.isSupported();

  @override
  bool get visible => _icon != null;

  @override
  Stream<String> get selections => _selections.stream;

  void _setMenu(TrayIcon icon, List<TrayEntry> entries) {
    final old = _menu;
    final oldItems = List<MenuItem>.of(_items);
    _items.clear();
    final menu = Menu.create();
    if (menu == null) return;
    for (final e in entries) {
      if (e.separator) {
        menu.addSeparator();
        continue;
      }
      final item = MenuItem.createWithLabelAndType(
        e.label,
        MenuItemType.normal,
      );
      if (item == null) continue;
      item
        ..isEnabled = e.enabled
        ..addListener((event) {
          if (event is MenuItemClickedEvent) _selections.add(e.id);
        });
      menu.addItem(item);
      _items.add(item);
    }
    icon.setContextMenu(menu);
    _menu = menu;
    // The system has the new menu now; the old objects can go.
    for (final i in oldItems) {
      i.dispose();
    }
    old?.dispose();
  }

  @override
  Future<void> show({
    required String iconAsset,
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  }) async {
    final icon = _icon ?? TrayIcon.create();
    if (icon == null) return;
    icon.icon = ImageAsset.fromAsset(iconAsset);
    _icon = icon;
    await update(menu: menu, tooltip: tooltip, title: title);
    icon.setVisible(true);
  }

  @override
  Future<void> update({
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  }) async {
    final icon = _icon;
    if (icon == null) return;
    icon
      ..setTooltip(tooltip)
      ..setTitle(title);
    _setMenu(icon, menu);
  }

  @override
  Future<void> hide() async {
    _icon?.setVisible(false);
    _icon?.dispose();
    _icon = null;
    for (final i in _items) {
      i.dispose();
    }
    _items.clear();
    _menu?.dispose();
    _menu = null;
  }
}
