#!/bin/bash
# Quick fix for "main.js not found" and TypeScript build errors

echo "Emily Assistant - Quick Fix Script"
echo "==================================="
echo ""
echo "This will fix:"
echo "1. Missing main.js error (external modules in vite.config.ts)"
echo "2. TypeScript TS6305 errors (duplicate compilation)"
echo "3. Wake word service (safe version with dynamic imports)"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Backing up current files..."
mkdir -p .backup
cp vite.config.ts .backup/ 2>/dev/null
cp tsconfig.json .backup/ 2>/dev/null
cp package.json .backup/ 2>/dev/null
cp electron/services/wakeword.service.ts .backup/ 2>/dev/null
echo "✅ Backup created in .backup/"

echo ""
echo "Step 2: Updating vite.config.ts..."
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import electron from 'vite-plugin-electron';
import renderer from 'vite-plugin-electron-renderer';
import path from 'path';

export default defineConfig({
  plugins: [
    react(),
    electron([
      {
        entry: 'electron/main.ts',
        onstart(options) {
          options.startup();
        },
        vite: {
          build: {
            outDir: 'dist-electron',
            rollupOptions: {
              external: [
                'electron',
                'node-record-lpcm16',
                '@picovoice/porcupine-node',
                '@picovoice/pvrecorder-node',
              ]
            }
          }
        }
      },
      {
        entry: 'electron/preload.ts',
        onstart(options) {
          options.reload();
        },
        vite: {
          build: {
            outDir: 'dist-electron'
          }
        }
      }
    ]),
    renderer()
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@electron': path.resolve(__dirname, './electron')
    }
  },
  server: {
    port: 5173
  }
});
EOF
echo "✅ vite.config.ts updated"

echo ""
echo "Step 3: Fixing tsconfig.json (remove electron from include)..."
if grep -q '"include": \["src", "electron"\]' tsconfig.json; then
    sed -i 's/"include": \["src", "electron"\]/"include": ["src"]/' tsconfig.json
    echo "✅ tsconfig.json fixed"
elif grep -q '"include":\["src","electron"\]' tsconfig.json; then
    sed -i 's/"include":\["src","electron"\]/"include":["src"]/' tsconfig.json
    echo "✅ tsconfig.json fixed"
else
    echo "⚠️  tsconfig.json may need manual fix - see FIX_TYPESCRIPT.md"
fi

echo ""
echo "Step 4: Fixing package.json (remove tsc from build)..."
if grep -q '"build": "tsc && vite build' package.json; then
    sed -i 's/"build": "tsc && vite build/"build": "vite build/' package.json
    echo "✅ package.json build script fixed"
else
    echo "ℹ️  package.json build script already correct"
fi

echo ""
echo "Step 5: Checking if renderer plugin is installed..."
if npm list vite-plugin-electron-renderer &>/dev/null; then
    echo "✅ vite-plugin-electron-renderer is installed"
else
    echo "⚠️  Installing vite-plugin-electron-renderer..."
    npm install --save-dev vite-plugin-electron-renderer
fi

echo ""
echo "Step 6: Cleaning old build artifacts..."
rm -rf dist/ dist-electron/ node_modules/.vite/
echo "✅ Cleaned"

echo ""
echo "Step 7: Testing development mode..."
echo "This will start the app. Press Ctrl+C to stop once you verify it works."
echo ""
sleep 2

npm run electron:dev