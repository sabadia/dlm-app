#!/usr/bin/env python3
"""Packs PNG files into a Windows .ico (PNG entries, Vista and later)."""
import struct
import sys

out, *pngs = sys.argv[1:]
entries = []
for path in pngs:
    data = open(path, "rb").read()
    w, h = struct.unpack(">II", data[16:24])
    entries.append((w, h, data))
header = struct.pack("<HHH", 0, 1, len(entries))
offset = 6 + 16 * len(entries)
table = b""
body = b""
for w, h, data in entries:
    table += struct.pack(
        "<BBBBHHII", w % 256, h % 256, 0, 0, 1, 32, len(data), offset + len(body)
    )
    body += data
open(out, "wb").write(header + table + body)
