import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';

/// The largest list file read from a drop.
const int maxDroppedListBytes = 1024 * 1024;

/// List files whose lines are links.
const Set<String> _listExtensions = {'txt', 'lst', 'urls', 'input'};

String _extension(String path) {
  final name = path.split(RegExp(r'[\\/]')).last;
  final dot = name.lastIndexOf('.');
  return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
}

/// How a dropped list file is read; tests substitute their own.
typedef ListReader = Future<String?> Function(String path);

Future<String?> _readList(String path) async {
  final file = File(path);
  try {
    if (await file.length() > maxDroppedListBytes) return null;
    return await file.readAsString();
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  }
}

/// What dropping [paths] on the window asks to add: `.torrent` files by path,
/// and the links written in a plain list file. Anything else is skipped.
Future<HandedOpen> openFromDrop(
  List<String> paths, {
  ListReader read = _readList,
}) async {
  final torrents = <String>[];
  final links = <String>[];
  for (final path in paths) {
    final ext = _extension(path);
    if (ext == 'torrent') {
      if (!torrents.contains(path)) torrents.add(path);
    } else if (_listExtensions.contains(ext)) {
      final text = await read(path);
      if (text == null) continue;
      for (final link in parseHanded(text.split(RegExp(r'\r?\n'))).links) {
        if (!links.contains(link)) links.add(link);
      }
    }
  }
  return HandedOpen(links: links, torrents: torrents);
}
