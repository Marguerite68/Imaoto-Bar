#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/../Sources/NowPlayingBar/Views/PreferencesView.swift"
INFO_PLIST="$SCRIPT_DIR/../Resources/Info.plist"

if rg -q 'Image\(systemName: "music\.note\.list"\)' "$SOURCE_FILE"; then
    echo 'FAIL: About preferences still show the generic music-note system icon'
    exit 1
fi

if ! rg -q 'Image\(nsImage: NSApp\.applicationIconImage\)' "$SOURCE_FILE"; then
    echo 'FAIL: About preferences do not use the application icon'
    exit 1
fi

if ! rg -q 'forInfoDictionaryKey: "CFBundleShortVersionString"' "$SOURCE_FILE"; then
    echo 'FAIL: About preferences do not read the bundled version'
    exit 1
fi

if [[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")" != '0.1.2' ]]; then
    echo 'FAIL: bundled short version is not 0.1.2'
    exit 1
fi

echo 'PASS: About preferences use the application icon and bundled version'
