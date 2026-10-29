#!/usr/bin/env bash
# Downloads a dlm release for this machine, checks it against the release's
# checksums and unpacks it. Prints the path of the dlm binary.
#
#   tools/fetch_daemon.sh <tag|latest> <outdir>
#
# Needs the GitHub CLI (`gh`) with access to sabadia/dlm-server.
set -euo pipefail
tag="${1:?release tag or latest}"
out="${2:?output directory}"
repo="sabadia/dlm-server"

if [ "$tag" = "latest" ]; then
  tag="$(gh release view -R "$repo" --json tagName -q .tagName)"
fi
version="${tag#v}"

case "$(uname -s)" in
  Linux*) os=linux; ext=tar.gz ;;
  Darwin*) os=darwin; ext=tar.gz ;;
  MINGW*|MSYS*|CYGWIN*) os=windows; ext=zip ;;
  *) echo "unsupported system $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  *) echo "unsupported architecture $(uname -m)" >&2; exit 1 ;;
esac

asset="dlm_${version}_${os}_${arch}.${ext}"
mkdir -p "$out"
cd "$out"
gh release download "$tag" -R "$repo" -p "$asset" -p "dlm_${version}_checksums.txt" --clobber

if command -v sha256sum >/dev/null 2>&1; then
  grep " ${asset}\$" "dlm_${version}_checksums.txt" | sha256sum -c - >&2
else
  grep " ${asset}\$" "dlm_${version}_checksums.txt" | shasum -a 256 -c - >&2
fi

if [ "$ext" = zip ]; then unzip -oq "$asset"; else tar -xzf "$asset"; fi
bin="$(find . -type f \( -name dlm -o -name dlm.exe \) | head -n 1)"
test -n "$bin" || { echo "no dlm binary in $asset" >&2; exit 1; }
chmod +x "$bin"
echo "$(cd "$(dirname "$bin")" && pwd)/$(basename "$bin")"
echo "dlm $version" >&2
