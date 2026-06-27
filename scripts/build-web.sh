#!/usr/bin/env bash
# Chasm: The Rift (PanzerChasm) — Emscripten web build (Linux / macOS / MSYS2)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/Chasm-Reverse"
WEB="$ROOT/web"
BUILD="$SRC/build-wasm"
GAMEFILES="$ROOT/gamefiles"
EMSDK_ROOT="${EMSDK_ROOT:-$ROOT/../bloodweb/emsdk}"
DEFAULT_GAME="${HOME}/Desktop/AwesomeChasm-main/game/CSM.BIN"

if [[ ! -f "$EMSDK_ROOT/emsdk_env.sh" ]]; then
  echo "Emscripten not found at $EMSDK_ROOT" >&2
  exit 1
fi

if [[ ! -f "$GAMEFILES/CSM.BIN" ]]; then
  if [[ -f "$DEFAULT_GAME" ]]; then
    echo "==> Importing CSM.BIN from AwesomeChasm-main"
    mkdir -p "$GAMEFILES"
    cp -f "$DEFAULT_GAME" "$GAMEFILES/CSM.BIN"
  else
    echo "Missing gamefiles/CSM.BIN — see gamefiles/README.md" >&2
    exit 1
  fi
fi

if [[ ! -f "$GAMEFILES/PanzerChasm.cfg" && -f "$SRC/default_PanzerChasm.cfg" ]]; then
  cp -f "$SRC/default_PanzerChasm.cfg" "$GAMEFILES/PanzerChasm.cfg"
fi

mkdir -p "$WEB" "$GAMEFILES"
# shellcheck source=/dev/null
source "$EMSDK_ROOT/emsdk_env.sh"

rm -rf "$BUILD"
mkdir -p "$BUILD"
cd "$BUILD"
emcmake cmake .. -DCMAKE_BUILD_TYPE=Release
emmake cmake --build . --target PanzerChasm -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

build_id="$(date +%Y%m%d%H%M%S)"
for f in PanzerChasm.js PanzerChasm.wasm PanzerChasm.data; do
  if [[ -f "$BUILD/$f" ]]; then
    cp -f "$BUILD/$f" "$WEB/$f"
    echo "==> Copied $f -> web/"
  fi
done

if [[ -f "$WEB/run.html" ]]; then
  sed -i.bak "s/var buildTag[[:space:]]*=[[:space:]]*'[^']*';/var buildTag   = '$build_id';/" "$WEB/run.html"
  rm -f "$WEB/run.html.bak"
fi

if [[ -d "$SRC/shaders" ]]; then
  rm -rf "$WEB/shaders"
  cp -a "$SRC/shaders" "$WEB/shaders"
fi

echo ""
echo "Build id: $build_id"
echo "Done. cd web && python3 serve.py"
