#!/bin/bash

# Create app icons from a 1024x1024 source image
# Usage: ./generate_icons.sh source_icon.png

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 source_icon.png"
    echo "Source icon should be 1024x1024 pixels"
    exit 1
fi

SOURCE=$1
ICONSET_DIR="StringsOrchestrator/Assets.xcassets/AppIcon.appiconset"

# Check if source file exists
if [ ! -f "$SOURCE" ]; then
    echo "Error: Source file '$SOURCE' not found"
    exit 1
fi

# Create icon sizes for iPhone
sips -z 40 40 "$SOURCE" --out "$ICONSET_DIR/icon-20@2x.png"
sips -z 60 60 "$SOURCE" --out "$ICONSET_DIR/icon-20@3x.png"
sips -z 58 58 "$SOURCE" --out "$ICONSET_DIR/icon-29@2x.png"
sips -z 87 87 "$SOURCE" --out "$ICONSET_DIR/icon-29@3x.png"
sips -z 80 80 "$SOURCE" --out "$ICONSET_DIR/icon-40@2x.png"
sips -z 120 120 "$SOURCE" --out "$ICONSET_DIR/icon-40@3x.png"
sips -z 120 120 "$SOURCE" --out "$ICONSET_DIR/icon-60@2x.png"
sips -z 180 180 "$SOURCE" --out "$ICONSET_DIR/icon-60@3x.png"

# Create icon sizes for iPad
sips -z 20 20 "$SOURCE" --out "$ICONSET_DIR/icon-20.png"
sips -z 29 29 "$SOURCE" --out "$ICONSET_DIR/icon-29.png"
sips -z 40 40 "$SOURCE" --out "$ICONSET_DIR/icon-40.png"
sips -z 76 76 "$SOURCE" --out "$ICONSET_DIR/icon-76.png"
sips -z 152 152 "$SOURCE" --out "$ICONSET_DIR/icon-76@2x.png"
sips -z 167 167 "$SOURCE" --out "$ICONSET_DIR/icon-83.5@2x.png"

# App Store icon
sips -z 1024 1024 "$SOURCE" --out "$ICONSET_DIR/icon-1024.png"

echo "Icons generated successfully in $ICONSET_DIR"