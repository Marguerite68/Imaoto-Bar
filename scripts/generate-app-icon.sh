#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/app-icon-generator"
MODULE_CACHE_DIR="$BUILD_DIR/module-cache"
ICONSET_DIR="$BUILD_DIR/ImaotoBar.iconset"
ARCHITECTURE="$(uname -m)"

mkdir -p "$MODULE_CACHE_DIR"

swiftc \
    -parse-as-library \
    -target "$ARCHITECTURE-apple-macosx13.0" \
    -vfsoverlay "$PROJECT_DIR/Resources/SwiftToolchainOverlay.yaml" \
    -module-cache-path "$MODULE_CACHE_DIR" \
    -o "$BUILD_DIR/GenerateAppIcon" \
    "$SCRIPT_DIR/GenerateAppIcon.swift"

"$BUILD_DIR/GenerateAppIcon" \
    "$PROJECT_DIR/Resources/Assets/AppIconArtwork.png" \
    "$PROJECT_DIR/Resources/Assets/AppIcon.png"

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

sips --resampleHeightWidth 16 16 "$PROJECT_DIR/Resources/Assets/AppIcon.png" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips --resampleHeightWidth 32 32 "$PROJECT_DIR/Resources/Assets/AppIcon.png" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips --resampleHeightWidth 64 64 "$PROJECT_DIR/Resources/Assets/AppIcon.png" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips --resampleHeightWidth 128 128 "$PROJECT_DIR/Resources/Assets/AppIcon.png" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips --resampleHeightWidth 256 256 "$PROJECT_DIR/Resources/Assets/AppIcon.png" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips --resampleHeightWidth 512 512 "$PROJECT_DIR/Resources/Assets/AppIcon.png" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips --resampleHeightWidth 1024 1024 "$PROJECT_DIR/Resources/Assets/AppIcon.png" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null

node "$SCRIPT_DIR/PackageAppIcon.js" "$ICONSET_DIR" "$PROJECT_DIR/Resources/ImaotoBar.icns"
