import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';
import 'package:test/test.dart';

Stream<List<int>> chunks(List<String> parts) =>
    Stream.fromIterable(parts.map(utf8.encode));

Future<List<SseFrame>> parse(List<String> parts) =>
    parseSse(chunks(parts)).toList();

List<String> summary(List<SseFrame> frames) => [
  for (final f in frames)
    switch (f) {
      SseData(:final message) =>
        '${message.event}|${message.id}|${message.data}',
      SseComment() => ':',
    },
];

void main() {
  test('parses id, event and data', () async {
    final frames = await parse([
      'id: b-1\nevent: task.status\ndata: {"a":1}\n\n',
    ]);
    expect(summary(frames), ['task.status|b-1|{"a":1}']);
  });

  test('joins multi-line data and defaults the event to message', () async {
    final frames = await parse(['data: one\ndata: two\n\n']);
    expect(summary(frames), ['message|null|one\ntwo']);
  });

  test('handles CRLF, CR and chunks cut anywhere', () async {
    const text = 'id: 1\r\nevent: e\r\ndata: x\r\n\r\nid: 2\rdata: y\r\r';
    final whole = summary(await parse([text]));
    expect(whole, ['e|1|x', 'message|2|y']);
    // The same text delivered one byte at a time (CRLF split across chunks).
    final bytes = utf8.encode(text);
    final onebyone = parseSse(
      Stream.fromIterable([
        for (final b in bytes) [b],
      ]),
    );
    expect(summary(await onebyone.toList()), whole);
  });

  test('multi-byte characters survive chunk boundaries', () async {
    final bytes = utf8.encode('data: héllo €\n\n');
    final frames = await parseSse(
      Stream.fromIterable([bytes.sublist(0, 8), bytes.sublist(8)]),
    ).toList();
    expect(summary(frames), ['message|null|héllo €']);
  });

  test('comments are reported, an id persists only for its message', () async {
    final frames = await parse([
      ': keep-alive\n\nid: 7\ndata: a\n\ndata: b\n\n',
    ]);
    expect(summary(frames), [':', 'message|7|a', 'message|null|b']);
  });

  test(
    'a message without data is not dispatched; a cut message is dropped',
    () async {
      final frames = await parse(['event: x\n\n', 'data: partial']);
      expect(frames, isEmpty);
    },
  );

  test(
    'a leading space is removed once; fields without colon are empty',
    () async {
      final frames = await parse(['data:  two spaces\ndata\n\n']);
      expect(summary(frames), ['message|null| two spaces\n']);
    },
  );

  test('an id containing NUL is ignored', () async {
    final frames = await parse(['id: a\u0000b\ndata: x\n\n']);
    expect(summary(frames), ['message|null|x']);
  });
}
