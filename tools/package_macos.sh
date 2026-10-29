#!/usr/bin/env bash
# Builds DLM.app for macOS (universal), puts the pinned dlm daemon inside it,
# signs it for the hardened runtime, and packs it into a DMG; with notary
# credentials it also notarises and staples the DMG.
#
#   tools/package_macos.sh <version> [outdir]
#
# Environment:
#   DLM_DAEMON_VERSION   daemon release to embed (default: the pinned one in
#                        packaging/daemon-version)
#   SIGN_IDENTITY        a "Developer ID Application: ..." identity. Unset or -:
#                        an ad-hoc signature, which keeps the bundle valid after
#                        the daemon is added but is not for distribution (no
#                        hardened runtime, no notarisation).
#   NOTARY_PROFILE       a keychain profile made with `xcrun notarytool
#                        store-credentials`; needs a real SIGN_IDENTITY
#   BUILD_NUMBER         CFBundleVersion (default: the commit count)
#   SKIP_BUILD=1         reuse an existing release build (for a quick rerun)
#
# Prints the DMG path. Run from the repository root on a Mac.
set -euo pipefail
version="${1:?version, for example 1.0.0}"
out="${2:-dist}"
root="$(pwd)"
daemon_version="${DLM_DAEMON_VERSION:-$(tr -d '[:space:]' < packaging/daemon-version)}"
# The bundle's own version is digits and dots; a pre-release suffix only goes
# into the file names.
build_name="${version%%-*}"
number="${BUILD_NUMBER:-$(git rev-list --count HEAD 2>/dev/null || echo 1)}"
app_build="apps/dlm_app/build/macos/Build/Products/Release/DLM.app"
mkdir -p "$out"
out="$(cd "$out" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

[ -n "${SKIP_BUILD:-}" ] || echo "==> building DLM $version ($number)" >&2
if [ -z "${SKIP_BUILD:-}" ]; then
  (cd apps/dlm_app && flutter build macos --release \
    --build-name "$build_name" --build-number "$number")
fi
archs="$(lipo -archs "$app_build/Contents/MacOS/DLM")"
case "$archs" in *arm64*x86_64*|*x86_64*arm64*) ;; *)
  echo "the app is not universal: $archs" >&2; exit 1 ;;
esac

echo "==> embedding dlm $daemon_version (universal)" >&2
app="$work/DLM.app"
cp -R "$app_build" "$app"
for arch in arm64 amd64; do
  DLM_OS=darwin DLM_ARCH="$arch" bash tools/fetch_daemon.sh "$daemon_version" "$work/dlm-$arch" > "$work/bin-$arch"
done
mkdir -p "$app/Contents/Resources/bin"
lipo -create "$(cat "$work/bin-arm64")" "$(cat "$work/bin-amd64")" \
  -output "$app/Contents/Resources/bin/dlm"
chmod 755 "$app/Contents/Resources/bin/dlm"
# The release has its licence next to the binary; keep it with the app.
cp LICENSE "$app/Contents/Resources/LICENSE-dlm-app.txt"

# The daemon was added after the build signed the bundle, so it is signed again
# either way. An ad-hoc signature (no identity) cannot use the hardened runtime
# with Flutter's frameworks, which are signed with it too.
identity="${SIGN_IDENTITY:--}"
if [ "$identity" = "-" ]; then
  echo "==> signing ad hoc (not for distribution)" >&2
  flags=(--force -s -)
else
  echo "==> signing with $identity (hardened runtime)" >&2
  flags=(--force --timestamp --options runtime -s "$identity")
fi
# Inside out: the daemon, every framework, then the app itself.
codesign "${flags[@]}" "$app/Contents/Resources/bin/dlm"
while IFS= read -r fw; do codesign "${flags[@]}" "$fw"; done < <(
  find "$app/Contents/Frameworks" -maxdepth 1 -name '*.framework')
codesign "${flags[@]}" \
  --entitlements apps/dlm_app/macos/Runner/Release.entitlements "$app"
codesign --verify --deep --strict --verbose=2 "$app" >&2

echo "==> making the DMG" >&2
stage="$work/dmg"
mkdir -p "$stage"
cp -R "$app" "$stage/DLM.app"
ln -s /Applications "$stage/Applications"
dmg="$out/DLM_${version}.dmg"
rm -f "$dmg"
hdiutil create -volname "DLM" -srcfolder "$stage" -fs HFS+ -format UDZO \
  -ov "$dmg" >/dev/null
if [ "$identity" != "-" ]; then
  codesign --force --timestamp -s "$identity" "$dmg"
fi

if [ -n "${NOTARY_PROFILE:-}" ]; then
  [ "$identity" != "-" ] || {
    echo "notarising needs a real SIGN_IDENTITY" >&2; exit 1; }
  echo "==> notarising (this waits for Apple)" >&2
  xcrun notarytool submit "$dmg" --keychain-profile "$NOTARY_PROFILE" --wait >&2
  xcrun stapler staple "$dmg" >&2
fi

(cd "$out" && shasum -a 256 "DLM_${version}.dmg" > "DLM_${version}.dmg.sha256")
echo "$dmg"
