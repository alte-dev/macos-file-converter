#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "=========================================="
echo "🔨 Building Alte File Converter for macOS..."
echo "=========================================="

APP_NAME="Alte File Converter"
EXEC_NAME="AlteFileConverter"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# 1. Clean previous builds
rm -rf "${APP_BUNDLE}" "FileConverter.app"

# 2. Generate AppIcon.icns if not present
if [ ! -f "AppIcon.icns" ]; then
    echo "🎨 Generating application icon..."
    swift generate_icon.swift
fi

# 3. Create App Bundle Directory Structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 4. Copy Icon to Resources
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "${RESOURCES_DIR}/AppIcon.icns"
fi

# 5. Create Info.plist
cat << 'EOF' > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AlteFileConverter</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.alte.FileConverter</string>
    <key>CFBundleName</key>
    <string>Alte File Converter</string>
    <key>CFBundleDisplayName</key>
    <string>Alte File Converter</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# 6. Compile Swift Sources (Universal Binary: Apple Silicon arm64 + Intel x86_64)
echo "⚡ Compiling Swift sources (Apple Silicon arm64)..."
swiftc \
    -O \
    -parse-as-library \
    -target arm64-apple-macos13.0 \
    -import-objc-header Sources/WebPBridge.h \
    -I Vendor/libwebp/include \
    Vendor/libwebp/lib/libwebp.a \
    Vendor/libwebp/lib/libsharpyuv.a \
    Sources/Localization.swift \
    Sources/Models.swift \
    Sources/ConverterEngine.swift \
    Sources/FileConverterViewModel.swift \
    Sources/Views/DropTargetView.swift \
    Sources/Views/SettingsView.swift \
    Sources/Views/ItemRowView.swift \
    Sources/Views/ContentView.swift \
    Sources/App.swift \
    -o "${MACOS_DIR}/${EXEC_NAME}_arm64"

echo "⚡ Compiling Swift sources (Intel x86_64)..."
if swiftc \
    -O \
    -parse-as-library \
    -target x86_64-apple-macos13.0 \
    -import-objc-header Sources/WebPBridge.h \
    -I Vendor/libwebp/include \
    Vendor/libwebp/lib/libwebp.a \
    Vendor/libwebp/lib/libsharpyuv.a \
    Sources/Localization.swift \
    Sources/Models.swift \
    Sources/ConverterEngine.swift \
    Sources/FileConverterViewModel.swift \
    Sources/Views/DropTargetView.swift \
    Sources/Views/SettingsView.swift \
    Sources/Views/ItemRowView.swift \
    Sources/Views/ContentView.swift \
    Sources/App.swift \
    -o "${MACOS_DIR}/${EXEC_NAME}_x86_64" 2>/dev/null; then
    echo "🔗 Merging Universal Binary (arm64 + x86_64)..."
    lipo -create -output "${MACOS_DIR}/${EXEC_NAME}" "${MACOS_DIR}/${EXEC_NAME}_arm64" "${MACOS_DIR}/${EXEC_NAME}_x86_64"
    rm -f "${MACOS_DIR}/${EXEC_NAME}_arm64" "${MACOS_DIR}/${EXEC_NAME}_x86_64"
else
    mv "${MACOS_DIR}/${EXEC_NAME}_arm64" "${MACOS_DIR}/${EXEC_NAME}"
fi

chmod +x "${MACOS_DIR}/${EXEC_NAME}"

# 7. Ad-hoc Codesign for macOS Gatekeeper
echo "🔏 Signing bundle (ad-hoc)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "=========================================="
echo "✅ Build complete:"
echo "👉 ${DIR}/${APP_BUNDLE}"
echo "=========================================="
