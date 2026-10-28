#!/usr/bin/env sh
# Regenerates the API client from spec/openapi-3.0.json.
set -eu
cd "$(dirname "$0")/.."
rm -rf lib/src/generated
dart run tool/prepare_spec.dart
dart run swagger_parser
dart run build_runner build --delete-conflicting-outputs
dart format lib/src/generated
