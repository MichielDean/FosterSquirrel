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

# Store the project root directory reliably
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)

# Define output paths
APK_DIR="${PROJECT_ROOT}/build/app/outputs/flutter-apk"
AAB_DIR="${PROJECT_ROOT}/build/app/outputs/bundle/release"
APK_FILE="FosterSquirrel-v${VERSION}.apk"
AAB_FILE="FosterSquirrel-v${VERSION}.aab"

# Update pubspec.yaml with new version
echo "Updating pubspec.yaml..."
sed -i "s/^version: .*/version: ${VERSION}/" "${PROJECT_ROOT}/pubspec.yaml"

# Build Android APK
echo "Building release APK..."
flutter build apk --release

# Build Android App Bundle
echo "Building release App Bundle..."
flutter build appbundle --release

# Rename and generate checksums for APK
echo "Processing APK..."
mv "${APK_DIR}/app-release.apk" "${APK_DIR}/${APK_FILE}"
sha256sum "${APK_DIR}/${APK_FILE}" > "${APK_DIR}/${APK_FILE}.sha256"

# Rename and generate checksums for AAB
echo "Processing App Bundle..."
mv "${AAB_DIR}/app-release.aab" "${AAB_DIR}/${AAB_FILE}"
sha256sum "${AAB_DIR}/${AAB_FILE}" > "${AAB_DIR}/${AAB_FILE}.sha256"

echo "✅ Release preparation complete for version $VERSION"
echo "   APK: ${APK_DIR}/${APK_FILE}"
echo "   AAB: ${AAB_DIR}/${AAB_FILE}"
