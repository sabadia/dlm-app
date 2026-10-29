#!/usr/bin/env bash
# Renders the Homebrew cask for a release.
#   tools/render_cask.sh <version> <sha256> > dlm-app.rb
set -euo pipefail

version="${1:?version, such as 1.2.3}"
sha="${2:?sha256 of DLM_<version>.dmg}"
root="$(cd "$(dirname "$0")/.." && pwd)"

[[ "$sha" =~ ^[0-9a-f]{64}$ ]] || { echo "not a sha256: $sha" >&2; exit 1; }
sed -e "s,@VERSION@,${version#v}," -e "s,@SHA256@,$sha," \
  "$root/packaging/homebrew/dlm-app.rb.tmpl"
