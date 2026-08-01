#!/bin/bash
# SessionStart hook: make `flutter analyze` and `flutter test` work in
# Claude Code on the web, where no Flutter SDK is present by default.
#
# Safe to re-run: an SDK already at the pinned revision is left alone.
set -euo pipefail

# Local machines already have their own Flutter; only set up the remote container.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Bump this when .metadata's revision changes (i.e. after `flutter upgrade`).
FLUTTER_VERSION="3.38.9"
FLUTTER_HOME="/opt/flutter"
ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# The SDK ships as a git checkout owned by root; without this every flutter
# command dies on "detected dubious ownership".
allow_git() { git config --global --add safe.directory "$FLUTTER_HOME" 2>/dev/null || true; }

# .metadata is the project's source of truth for which SDK build to run.
want_rev="$(awk '/^  revision:/ {gsub(/"/, "", $2); print $2}' "$PROJECT_DIR/.metadata")"
have_rev() { git -C "$FLUTTER_HOME" rev-parse HEAD 2>/dev/null || true; }

allow_git
if [ -z "$want_rev" ] || [ "$(have_rev)" != "$want_rev" ]; then
  echo "Installing Flutter ${FLUTTER_VERSION}..."
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL -o "$tmp/$ARCHIVE" "$BASE_URL/$ARCHIVE"
  rm -rf "$FLUTTER_HOME"
  tar -xJf "$tmp/$ARCHIVE" -C "$(dirname "$FLUTTER_HOME")"
  allow_git

  if [ -n "$want_rev" ] && [ "$(have_rev)" != "$want_rev" ]; then
    echo "WARNING: installed Flutter ${FLUTTER_VERSION} is revision $(have_rev)," >&2
    echo "         but .metadata pins $want_rev." >&2
    echo "         Update FLUTTER_VERSION in $0 to match." >&2
  fi
else
  echo "Flutter ${FLUTTER_VERSION} already installed."
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

# Persist PATH so later tool calls in this session find flutter/dart.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_HOME/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Analyzer and tests both need the package config resolved.
cd "$PROJECT_DIR"
flutter pub get

flutter --version
