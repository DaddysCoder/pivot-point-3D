#!/usr/bin/env bash
# Export Pivot Point 3D release builds (Linux / Windows / Web).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-}"
if [[ -z "$GODOT" ]]; then
  if [[ -x /tmp/godot-install/Godot_v4.4.1-stable_linux.x86_64 ]]; then
    GODOT=/tmp/godot-install/Godot_v4.4.1-stable_linux.x86_64
  elif command -v godot4 >/dev/null 2>&1; then
    GODOT="$(command -v godot4)"
  elif command -v godot >/dev/null 2>&1; then
    GODOT="$(command -v godot)"
  else
    echo "Set GODOT to a Godot 4.4.x binary." >&2
    exit 1
  fi
fi

BUILD_ROOT="$(cd "$ROOT/.." && pwd)/build"
mkdir -p "$BUILD_ROOT/linux" "$BUILD_ROOT/windows" "$BUILD_ROOT/web"

echo "Using Godot: $GODOT"
"$GODOT" --headless --path "$ROOT" --import >/dev/null 2>&1 || true

export_one() {
  local preset="$1"
  echo "=== Exporting: $preset ==="
  "$GODOT" --headless --path "$ROOT" --export-release "$preset" 2>&1
}

TARGETS="${1:-all}"
case "$TARGETS" in
  linux) export_one "Linux Desktop" ;;
  windows) export_one "Windows Desktop" ;;
  web) export_one "Web" ;;
  all)
    export_one "Linux Desktop"
    export_one "Windows Desktop"
    export_one "Web"
    ;;
  *)
    echo "Usage: $0 [all|linux|windows|web]" >&2
    exit 1
    ;;
esac

echo "Builds written under: $BUILD_ROOT"
find "$BUILD_ROOT" -type f | head -40
