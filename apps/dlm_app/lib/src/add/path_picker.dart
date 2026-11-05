import 'package:file_selector/file_selector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';
import '../onboarding/folder_picker.dart';
import 'folder_browser.dart';

/// Whether files can be browsed for: the server is this computer, so the
/// system's file dialog shows the files it will see.
bool canBrowseFiles(BuildContext context) => ProviderScope.containerOf(
  context,
  listen: false,
).read(activeProfileProvider).isLocal;

/// Lets the user choose a folder. For the server on this computer that is the
/// system's folder dialog (Finder, Explorer, the desktop's file chooser);
/// for another server, or where the system offers no dialog, the browser of
/// the server's own folders. Returns the path, or null when cancelled. The
/// text of the field stays editable: this only fills it in.
Future<String?> pickFolderPath(BuildContext context, {String? start}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  if (container.read(activeProfileProvider).isLocal) {
    try {
      return await container
          .read(folderPickerProvider)
          .pick(initial: start == null || start.isEmpty ? null : start);
    } on Object {
      // This system has no folder dialog: use the server's folder browser.
    }
  }
  if (!context.mounted) return null;
  return pickDaemonFolder(context, start: start);
}

/// Lets the user choose a file on this computer (only offered when
/// [canBrowseFiles]); null when cancelled.
Future<String?> pickFilePath({List<String>? extensions}) async {
  final file = await openFile(
    acceptedTypeGroups: [
      if (extensions != null) XTypeGroup(extensions: extensions),
    ],
  );
  return file?.path;
}
