# Voice Arena: Real-Time Voice Chat platform

A low-latency, interruption-capable voice assistant that combines real-time Speech-to-Text, LLM reasoning, and expressive Text-to-Speech into a seamless conversational experience.

Speak naturally. Interrupt anytime. Switch voices. Change personas.

voice agents built  fully using open source models hosted and orchestrated locally.

<br>

### Demo

https://github.com/user-attachments/assets/e420c693-164b-4413-925f-22a85d77390a

<br>

## Features

- Real-time streaming Speech-to-Text (FasterWhisper)
- LLM reasoning via Mixtral
- Expressive Text-to-Speech with Kokoro
- Multiple voices and personas
- Interruptible responses (barge-in support)
- Modular architecture
- Fully local and open-source pipeline

<br>


## System Architecture Overview

### Component Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                         Client (Browser)                     │
│  ┌────────────┐  ┌────────────┐  ┌─────────────────────┐   │
│  │ Microphone │→ │  WebSocket │ ← │ Audio Playback      │   │
│  └────────────┘  └─────┬──────┘  └─────────────────────┘   │
└────────────────────────┼────────────────────────────────────┘
                         │ (Audio PCM + Metadata)
┌────────────────────────┼────────────────────────────────────┐
│                   Server (FastAPI)                           │
│  ┌─────────────────────┼────────────────────────────────┐   │
│  │  process_incoming_data (async task)                   │   │
│  │  • Receives audio chunks with timestamps & flags      │   │
│  │  • Applies backpressure (queue limit: 50 chunks)      │   │
│  │  • Handles JSON control messages                      │   │
│  └────────────────────┬───────────────────────────────────┘   │
│                       ▼                                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │    AudioInputProcessor (global component)             │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  VAD (Voice Activity Detection)                │  │   │
│  │  │  • Silero VAD model (30ms chunks)             │  │   │
│  │  │  • Dynamic thresholds (speech/silence)         │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  WhisperTranscriber                            │  │   │
│  │  │  • Faster-Whisper model                        │  │   │
│  │  │  • Streaming transcription (512ms chunks)      │  │   │
│  │  │  • Partial/potential/final callbacks           │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  TurnDetection                                 │  │   │
│  │  │  • Sentence completion classifier              │  │   │
│  │  │  • Dynamic pause calculation                   │  │   │
│  │  │  • Punctuation analysis                        │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         ▼ (transcribed text)                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  TranscriptionCallbacks (per-connection state)        │   │
│  │  • Manages connection-specific flags                  │   │
│  │  • Coordinates with SpeechPipelineManager            │   │
│  │  • Handles user interruptions                        │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         ▼                                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  SpeechPipelineManager (global orchestrator)         │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  Request Queue Processor (thread)              │  │   │
│  │  │  • Handles 'prepare', 'abort', 'finish'        │  │   │
│  │  │  • Text similarity deduplication               │  │   │
│  │  │  • Initiates LLM generation                    │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  LLM Worker Thread                             │  │   │
│  │  │  • Streams tokens from LLM                     │  │   │
│  │  │  • Identifies quick answer boundary            │  │   │
│  │  │  • Signals TTS workers                         │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  Quick TTS Worker Thread                       │  │   │
│  │  │  • Synthesizes first part of response          │  │   │
│  │  │  • Produces audio chunks immediately           │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  Final TTS Worker Thread                       │  │   │
│  │  │  • Synthesizes remaining response              │  │   │
│  │  │  • Continues from LLM stream                   │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         ▼ (audio chunks)                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  send_tts_chunks (async task)                        │   │
│  │  • Upsamples audio (8kHz → 24kHz)                    │   │
│  │  • Base64 encodes chunks                             │   │
│  │  • Sends to client via WebSocket                     │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

---


### Design Goals

- Low latency
- Streaming-first pipeline
- Early response playback
- Immediate interruption handling
- Clean persona conditioning within LLM prompts

<br>

## Tech Stack

- STT: FasterWhisper  
- LLM: Mixtral  
- TTS: Kokoro  
- Python backend  
- Streaming audio pipeline

<br>

## Requirements:

- Python 3.10+
- FFmpeg installed
- GPU recommended







