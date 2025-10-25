#!/bin/bash
set -e  # Exit on error
set -u  # Exit on undefined variable

# Release preparation script for semantic-release
# Usage: ./scripts/prepare-release.sh <version>

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Error: Version argument required"
  echo "Usage: $0 <version>"
  exit 1
fi

echo "Preparing release version: $VERSION"

# Store the project root directory
PROJECT_ROOT=$(pwd)

# Calculate build number from semantic version
# Format: major * 10000 + minor * 100 + patch
IFS='.' read -ra VERSION_PARTS <<< "$VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}
BUILD_NUMBER=$((MAJOR * 10000 + MINOR * 100 + PATCH))

echo "Build number: $BUILD_NUMBER"

# Update pubspec.yaml with new version
echo "Updating pubspec.yaml..."
sed -i "s/^version: .*/version: ${VERSION}+${BUILD_NUMBER}/" pubspec.yaml

# Build Android APK
echo "Building release APK..."
flutter build apk --release

# Build Android App Bundle
echo "Building release App Bundle..."
flutter build appbundle --release

# Rename APK with version
echo "Renaming APK..."
mv build/app/outputs/flutter-apk/app-release.apk \
   build/app/outputs/flutter-apk/FosterSquirrel-v${VERSION}.apk

# Rename AAB with version
echo "Renaming App Bundle..."
mv build/app/outputs/bundle/release/app-release.aab \
   build/app/outputs/bundle/release/FosterSquirrel-v${VERSION}.aab

# Generate SHA256 checksum for APK
echo "Generating APK checksum..."
cd "${PROJECT_ROOT}/build/app/outputs/flutter-apk"
sha256sum FosterSquirrel-v${VERSION}.apk > FosterSquirrel-v${VERSION}.apk.sha256

# Generate SHA256 checksum for AAB
echo "Generating App Bundle checksum..."
cd "${PROJECT_ROOT}/build/app/outputs/bundle/release"
sha256sum FosterSquirrel-v${VERSION}.aab > FosterSquirrel-v${VERSION}.aab.sha256

echo "✅ Release preparation complete for version $VERSION"
