import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';
import { WakeWordService } from './electron/services/wakeword.service';
import { WhisperService } from './electron/services/whisper.service';
import { TTSService } from './electron/services/tts.service';
import { LLMService } from './electron/services/llm.service';

let mainWindow: BrowserWindow | null = null;
let wakeWordService: WakeWordService | null = null;
let whisperService: WhisperService | null = null;
let ttsService: TTSService | null = null;
let llmService: LLMService | null = null;

const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 3480,
    height: 2160,
    fullscreen: false, // Set to true for production
    frame: true, // Set to false for production
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    backgroundColor: '#000000'
  });

  if (isDev) {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

async function initializeServices() {
  try {
    // Initialize TTS Service
    ttsService = new TTSService('http://192.168.0.18:8888');
    console.log('TTS Service initialized');

    // Initialize LLM Service
    llmService = new LLMService('http://192.168.0.18:1234');
    console.log('LLM Service initialized');

    // Initialize Whisper Service
    whisperService = new WhisperService();
    await whisperService.initialize();
    console.log('Whisper Service initialized');

    // Initialize Wake Word Service (Porcupine)
    wakeWordService = new WakeWordService((detected) => {
      if (detected && mainWindow) {
        console.log('Wake word "Hey Emily" detected!');
        mainWindow.webContents.send('wake-word-detected');
      }
    });
    await wakeWordService.initialize();
    console.log('Wake Word Service initialized');

  } catch (error) {
    console.error('Error initializing services:', error);
  }
}

// IPC Handlers
ipcMain.handle('start-wake-word', async () => {
  try {
    if (wakeWordService) {
      await wakeWordService.start();
      return { success: true };
    }
    return { success: false, error: 'Wake word service not initialized' };
  } catch (error) {
    console.error('Error starting wake word:', error);
    return { success: false, error: String(error) };
  }
});

ipcMain.handle('stop-wake-word', async () => {
  try {
    if (wakeWordService) {
      await wakeWordService.stop();
      return { success: true };
    }
    return { success: false, error: 'Wake word service not initialized' };
  } catch (error) {
    console.error('Error stopping wake word:', error);
    return { success: false, error: String(error) };
  }
});

ipcMain.handle('start-recording', async () => {
  try {
    if (whisperService) {
      await whisperService.startRecording();
      return { success: true };
    }
    return { success: false, error: 'Whisper service not initialized' };
  } catch (error) {
    console.error('Error starting recording:', error);
    return { success: false, error: String(error) };
  }
});

ipcMain.handle('stop-recording', async () => {
  try {
    if (whisperService) {
      const transcription = await whisperService.stopRecording();
      return { success: true, transcription };
    }
    return { success: false, error: 'Whisper service not initialized' };
  } catch (error) {
    console.error('Error stopping recording:', error);
    return { success: false, error: String(error) };
  }
});

ipcMain.handle('send-to-llm', async (event, message: string, history: any[]) => {
  try {
    if (llmService) {
      const response = await llmService.sendMessage(message, history);
      return { success: true, response };
    }
    return { success: false, error: 'LLM service not initialized' };
  } catch (error) {
    console.error('Error sending to LLM:', error);
    return { success: false, error: String(error) };
  }
});

ipcMain.handle('speak-text', async (event, text: string) => {
  try {
    if (ttsService) {
      const audioUrl = await ttsService.speak(text);
      return { success: true, audioUrl };
    }
    return { success: false, error: 'TTS service not initialized' };
  } catch (error) {
    console.error('Error speaking text:', error);
    return { success: false, error: String(error) };
  }
});

// App lifecycle
app.whenReady().then(async () => {
  createWindow();
  await initializeServices();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (wakeWordService) {
    wakeWordService.cleanup();
  }
  if (whisperService) {
    whisperService.cleanup();
  }
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('will-quit', () => {
  if (wakeWordService) {
    wakeWordService.cleanup();
  }
  if (whisperService) {
    whisperService.cleanup();
  }
});