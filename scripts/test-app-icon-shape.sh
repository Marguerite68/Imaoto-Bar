#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/app-icon-shape-test"
MODULE_CACHE_DIR="$BUILD_DIR/module-cache"
ICONSET_DIR="$BUILD_DIR/ImaotoBar.iconset"
ARCHITECTURE="$(uname -m)"

mkdir -p "$MODULE_CACHE_DIR"

swiftc \
    -parse-as-library \
    -target "$ARCHITECTURE-apple-macosx13.0" \
    -vfsoverlay "$PROJECT_DIR/Resources/SwiftToolchainOverlay.yaml" \
    -module-cache-path "$MODULE_CACHE_DIR" \
    -o "$BUILD_DIR/AppIconShapeHarness" \
    "$PROJECT_DIR/scripts/AppIconShapeHarness.swift"

"$BUILD_DIR/AppIconShapeHarness" "$PROJECT_DIR/Resources/Assets/AppIcon.png"

rm -rf "$ICONSET_DIR"
iconutil --convert iconset --output "$ICONSET_DIR" "$PROJECT_DIR/Resources/ImaotoBar.icns"
"$BUILD_DIR/AppIconShapeHarness" "$ICONSET_DIR/icon_512x512@2x.png"
