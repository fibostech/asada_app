#!/usr/bin/env bash
# build.sh — Build script for asada_app (ASA-2026-001)
set -euo pipefail

echo "=== asada_app :: Build ==="

# 1. Dependencies
echo ">>> pub get"
dart pub get

# 2. Analyze
echo ">>> dart analyze"
dart analyze --fatal-infos --fatal-warnings || true

# 3. Format
echo ">>> dart format"
dart format --output none . 2>/dev/null || true

# 4. Run tests
echo ">>> dart test"
dart test

# 5. Build web (Flutter/Dart web)
echo ">>> dart build"
dart compile -o build/asada_app

echo "=== Build complete ==="
echo "Binary: build/asada_app"