#!/bin/bash
# Verify all required files exist

echo "Checking Emily Assistant Project Files..."
echo "==========================================="
echo ""

MISSING=0
FOUND=0

check_file() {
    if [ -f "$1" ]; then
        echo "✓ $1"
        FOUND=$((FOUND + 1))
    else
        echo "✗ MISSING: $1"
        MISSING=$((MISSING + 1))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo "✓ $1/"
        FOUND=$((FOUND + 1))
    else
        echo "✗ MISSING: $1/"
        MISSING=$((MISSING + 1))
    fi
}

echo "Configuration Files:"
check_file "package.json"
check_file "tsconfig.json"
check_file "tsconfig.node.json"
check_file "vite.config.ts"
check_file "tailwind.config.js"
check_file "postcss.config.js"
check_file "index.html"
check_file ".gitignore"
check_file ".env.example"

echo ""
echo "Electron Files:"
check_file "electron/main.ts"
check_file "electron/preload.ts"
check_file "electron/services/wakeword.service.ts"
check_file "electron/services/whisper.service.ts"
check_file "electron/services/tts.service.ts"
check_file "electron/services/llm.service.ts"

echo ""
echo "React Source Files:"
check_file "src/main.tsx"
check_file "src/App.tsx"
check_file "src/App.css"
check_file "src/index.css"

echo ""
echo "Components:"
check_file "src/components/AudioVisualizer/useAudioVisualizerCircle.ts"
check_file "src/components/AudioVisualizer/PositionedAudioVisualizer.tsx"
check_file "src/components/AudioVisualizer/cssUtil.ts"

echo ""
echo "Pages:"
check_file "src/pages/VoiceScreen.tsx"
check_file "src/pages/ModuleScreen.tsx"

echo ""
echo "Services:"
check_file "src/services/ipc.service.ts"

echo ""
echo "Types:"
check_file "src/types/chatHistory.ts"

echo ""
echo "MagicMirror:"
check_file "src/magicmirror/moduleLoader.ts"
check_file "src/magicmirror/moduleRegistry.ts"
check_file "src/magicmirror/modules/clock.module.ts"
check_file "src/magicmirror/modules/weather.module.ts"
check_file "src/magicmirror/modules/calendar.module.ts"
check_file "src/magicmirror/modules/reminders.module.ts"

echo ""
echo "==========================================="
echo "Summary:"
echo "  Found: $FOUND"
echo "  Missing: $MISSING"
echo ""

if [ $MISSING -gt 0 ]; then
    echo "⚠️  Some files are missing!"
    echo "Please ensure all files were copied correctly from the outputs directory."
    exit 1
else
    echo "✅ All required files are present!"
    exit 0
fi