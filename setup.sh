#!/bin/bash
# Emily Assistant Setup Script

set -e

echo "======================================"
echo "Emily Voice Assistant Setup"
echo "======================================"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi
echo "✅ Node.js $(node --version) found"

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi
echo "✅ npm $(npm --version) found"

# Install dependencies
echo ""
echo "📦 Installing npm dependencies..."
npm install

# Check for audio tools
echo ""
echo "🔊 Checking audio tools..."

if ! command -v mpg123 &> /dev/null; then
    echo "⚠️  mpg123 not found. Install with: sudo apt-get install mpg123"
else
    echo "✅ mpg123 found"
fi

if ! command -v arecord &> /dev/null; then
    echo "⚠️  arecord (ALSA) not found. Install with: sudo apt-get install alsa-utils"
else
    echo "✅ arecord found"
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "⚠️  ffmpeg not found. Install with: sudo apt-get install ffmpeg"
else
    echo "✅ ffmpeg found"
fi

# Check for Whisper.cpp
echo ""
echo "🎙️  Checking Whisper.cpp..."
if [ -z "$WHISPER_CPP_PATH" ]; then
    echo "⚠️  WHISPER_CPP_PATH not set."
    echo "   Setup instructions:"
    echo "   1. git clone https://github.com/ggerganov/whisper.cpp"
    echo "   2. cd whisper.cpp && make"
    echo "   3. bash ./models/download-ggml-model.sh base.en"
    echo "   4. export WHISPER_CPP_PATH=/path/to/whisper.cpp/main"
    echo "   5. export WHISPER_MODEL_PATH=/path/to/whisper.cpp/models/ggml-base.en.bin"
else
    if [ -f "$WHISPER_CPP_PATH" ]; then
        echo "✅ Whisper.cpp found at $WHISPER_CPP_PATH"
    else
        echo "⚠️  Whisper.cpp not found at $WHISPER_CPP_PATH"
    fi
fi

# Check for Porcupine
echo ""
echo "🎤 Checking Porcupine wake word..."
if [ -z "$PICOVOICE_ACCESS_KEY" ]; then
    echo "⚠️  PICOVOICE_ACCESS_KEY not set."
    echo "   Setup instructions:"
    echo "   1. Sign up at https://console.picovoice.ai/"
    echo "   2. Get your access key"
    echo "   3. Train 'Hey Emily' wake word"
    echo "   4. export PICOVOICE_ACCESS_KEY=your-key"
else
    echo "✅ Porcupine access key is set"
fi

# Test TTS Server
echo ""
echo "🔊 Testing TTS Server..."
TTS_URL="${TTS_SERVER_URL:-http://192.168.0.18:8888}"
if curl -s --connect-timeout 5 "$TTS_URL/" > /dev/null 2>&1; then
    echo "✅ TTS Server accessible at $TTS_URL"
else
    echo "⚠️  TTS Server not accessible at $TTS_URL"
    echo "   Make sure your TTS server is running"
fi

# Test LLM Server
echo ""
echo "🤖 Testing LLM Server..."
LLM_URL="${LLM_SERVER_URL:-http://192.168.0.18:1234}"
if curl -s --connect-timeout 5 "$LLM_URL/" > /dev/null 2>&1; then
    echo "✅ LLM Server accessible at $LLM_URL"
else
    echo "⚠️  LLM Server not accessible at $LLM_URL"
    echo "   Make sure LM Studio is running with a model loaded"
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created. Please edit it with your configuration."
fi

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. Run 'npm run electron:dev' to start development server"
echo ""
echo "For full functionality, make sure to:"
echo "- Install and configure Whisper.cpp"
echo "- Set up Porcupine wake word detection"
echo "- Verify TTS and LLM servers are running"
echo ""