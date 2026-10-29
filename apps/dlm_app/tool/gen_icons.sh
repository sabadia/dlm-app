#!/bin/sh
# Regenerates every app icon from the painted DLM mark (macOS only: sips).
# Run from apps/dlm_app:  sh tool/gen_icons.sh
set -eu
export PATH="$HOME/fvm/versions/3.47.8/bin:$PATH"
OUT="$(pwd)/build/icons"
rm -rf "$OUT" && mkdir -p "$OUT/sizes"
DLM_ICON_OUT="$OUT" flutter test tool/gen_icons.dart
for s in 16 32 48 64 128 256 512 1024; do
  sips -z "$s" "$s" "$OUT/mark_1024.png" --out "$OUT/sizes/$s.png" >/dev/null
  cp "$OUT/sizes/$s.png" "assets/icon/dlm_$s.png"
  cp "$OUT/sizes/$s.png" "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$s.png"
done
cp "$OUT/tray_template.png" assets/icon/tray_template.png
python3 tool/make_ico.py windows/runner/resources/app_icon.ico \
  "$OUT/sizes/16.png" "$OUT/sizes/32.png" "$OUT/sizes/48.png" "$OUT/sizes/256.png"
echo "icons written"
