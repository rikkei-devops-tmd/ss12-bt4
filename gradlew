#!/bin/sh
set -e

GRADLE_VERSION="8.7"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"
GRADLE_DIR="$GRADLE_USER_HOME/wrapper/dists/gradle-$GRADLE_VERSION-bin"
GRADLE_BIN="$GRADLE_DIR/gradle-$GRADLE_VERSION/bin/gradle"

if [ ! -x "$GRADLE_BIN" ]; then
    mkdir -p "$GRADLE_DIR"
    TMP_ZIP="/tmp/gradle-$GRADLE_VERSION-bin.zip"
    if command -v curl >/dev/null 2>&1; then
        curl -sSL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" -o "$TMP_ZIP"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" -O "$TMP_ZIP"
    fi
    unzip -q -o "$TMP_ZIP" -d "$GRADLE_DIR"
    rm -f "$TMP_ZIP"
fi

exec "$GRADLE_BIN" "$@"