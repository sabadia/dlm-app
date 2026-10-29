#!/usr/bin/env bash
# Builds DLM for Linux x64: the app with the pinned dlm daemon inside it, a
# tar.gz, and a .deb and .rpm (with nfpm when it is installed).
#
#   tools/package_linux.sh <version> [outdir]
#
# Run from the repository root on Linux with the Flutter Linux toolchain
# (clang, cmake, ninja, GTK 3 and the plugin libraries).
set -euo pipefail
version="${1:?version, for example 1.0.0}"
out="${2:-dist}"
daemon_version="${DLM_DAEMON_VERSION:-$(tr -d '[:space:]' < packaging/daemon-version)}"
build_name="${version%%-*}"
number="${BUILD_NUMBER:-$(git rev-list --count HEAD 2>/dev/null || echo 1)}"
mkdir -p "$out"
out="$(cd "$out" && pwd)"
bundle="$PWD/apps/dlm_app/build/linux/x64/release/bundle"

if [ -z "${SKIP_BUILD:-}" ]; then
  (cd apps/dlm_app && flutter build linux --release \
    --build-name "$build_name" --build-number "$number")
fi
test -x "$bundle/dlm_app" || { echo "no build in $bundle" >&2; exit 1; }

# The daemon goes where the app looks for it: bin/dlm next to the app.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
daemon="$(DLM_OS=linux DLM_ARCH=amd64 bash tools/fetch_daemon.sh "$daemon_version" "$work/dlm")"
mkdir -p "$bundle/bin"
cp "$daemon" "$bundle/bin/dlm"
chmod 755 "$bundle/bin/dlm"
cp LICENSE "$bundle/LICENSE.txt"

# tar.gz
tgz="$out/DLM_${version}_linux_x64.tar.gz"
tar -C "$(dirname "$bundle")" -czf "$tgz" --transform 's,^bundle,DLM,' bundle

# Metainfo with the version and date filled in.
sed -e "s/@VERSION@/$version/" -e "s/@DATE@/$(date -u +%Y-%m-%d)/" \
  packaging/linux/io.github.sabadia.dlm.metainfo.xml \
  > packaging/linux/io.github.sabadia.dlm.metainfo.xml.rendered
trap 'rm -rf "$work" packaging/linux/io.github.sabadia.dlm.metainfo.xml.rendered' EXIT

# .deb and .rpm
if command -v nfpm >/dev/null 2>&1; then
  export VERSION="$version" BUNDLE="$bundle" NFPM_ARCH=amd64
  nfpm package -p deb -f packaging/linux/nfpm.yaml -t "$out/DLM_${version}_linux_amd64.deb"
  nfpm package -p rpm -f packaging/linux/nfpm.yaml -t "$out/DLM_${version}_linux_x86_64.rpm"
else
  echo "nfpm is not installed: no .deb or .rpm" >&2
fi

(cd "$out" && for f in DLM_${version}_linux_*; do
  case "$f" in *.sha256) continue ;; esac
  sha256sum "$f" > "$f.sha256"; echo "$out/$f"
done)
