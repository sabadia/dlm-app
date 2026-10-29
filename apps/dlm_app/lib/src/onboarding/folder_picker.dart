import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the user choose a folder on this computer.
// ignore: one_member_abstracts
abstract interface class FolderPicker {
  /// Asks for a folder, starting at [initial]; null when cancelled.
  Future<String?> pick({String? initial, String? title});
}

/// The operating system's folder dialog.
class SystemFolderPicker implements FolderPicker {
  /// Creates the picker.
  const SystemFolderPicker();

  @override
  Future<String?> pick({String? initial, String? title}) =>
      getDirectoryPath(initialDirectory: initial, confirmButtonText: title);
}

/// The folder dialog; replaced in tests.
final folderPickerProvider = Provider<FolderPicker>(
  (ref) => const SystemFolderPicker(),
);
