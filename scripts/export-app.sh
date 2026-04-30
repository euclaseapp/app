#!/usr/bin/env bash

set -euo pipefail

PROJECT_PATH="Euclase.xcodeproj"
TARGET_NAME="${TARGET_NAME:-Euclase}"
SCHEME_NAME="${SCHEME_NAME:-$TARGET_NAME}"
CONFIGURATION="${CONFIGURATION:-Release}"
OUTPUT_DIR="${OUTPUT_DIR:-dist}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Error: project not found at $PROJECT_PATH" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Building $TARGET_NAME ($CONFIGURATION)..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME_NAME" \
  -configuration "$CONFIGURATION" \
  build

BUILD_SETTINGS="$(xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME_NAME" \
  -configuration "$CONFIGURATION" \
  -showBuildSettings)"

TARGET_BUILD_DIR="$(echo "$BUILD_SETTINGS" | awk -F' = ' '/^[[:space:]]*TARGET_BUILD_DIR = / { print $2; exit }')"
FULL_PRODUCT_NAME="$(echo "$BUILD_SETTINGS" | awk -F' = ' '/^[[:space:]]*FULL_PRODUCT_NAME = / { print $2; exit }')"

if [[ -z "$TARGET_BUILD_DIR" || -z "$FULL_PRODUCT_NAME" ]]; then
  echo "Error: could not determine built app location from Xcode build settings" >&2
  exit 1
fi

APP_PATH="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"
DEST_APP_PATH="$OUTPUT_DIR/$TARGET_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: built app not found at $APP_PATH" >&2
  exit 1
fi

rm -rf "$DEST_APP_PATH"
cp -R "$APP_PATH" "$DEST_APP_PATH"

echo "Exported app: $DEST_APP_PATH"
