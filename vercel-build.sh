#!/usr/bin/env bash
# Vercel build for the Flutter web app (Vercel's build image has no Flutter).
# Installs the pinned Flutter SDK, then builds into build/web (see vercel.json).
# Optional Vercel env vars: FLUTTER_VERSION, API_BASE_URL.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.44.6}"
API_BASE_URL="${API_BASE_URL:-https://ez-farms-api.onrender.com}"
SDK_DIR="$HOME/flutter-sdk"

# Flutter's tool needs unzip/xz to fetch the Dart SDK and web engine artifacts
for tool in unzip xz; do
  command -v "$tool" >/dev/null 2>&1 || dnf install -y "$tool" >/dev/null
done

if [ ! -x "$SDK_DIR/bin/flutter" ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$SDK_DIR"
fi
export PATH="$SDK_DIR/bin:$PATH"
git config --global --add safe.directory "$SDK_DIR"

flutter config --no-analytics >/dev/null
flutter --version
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
