#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LVGL_ROOT="$ROOT_DIR/lib/lvgl"
BUILD_DIR="$LVGL_ROOT/build/crystal"
OUTPUT_LIB="$BUILD_DIR/liblvgl.so"

mkdir -p "$BUILD_DIR"
mapfile -t SOURCES < <(find "$LVGL_ROOT/src" -type f -name '*.c' | sort)

clang \
  -shared \
  -fPIC \
  -O2 \
  -fuse-ld=lld \
  -I"$LVGL_ROOT" \
  -I"$LVGL_ROOT/src" \
  -DLV_CONF_SKIP=1 \
  -DLV_USE_TEST=1 \
  -DLV_USE_SNAPSHOT=1 \
  "${SOURCES[@]}" \
  -o "$OUTPUT_LIB"

echo "Built $OUTPUT_LIB with LV_USE_TEST=1 and LV_USE_SNAPSHOT=1"
