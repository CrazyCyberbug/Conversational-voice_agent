# Voice Arena: Real-Time Voice Chat platform

A low-latency, interruption-capable voice assistant that combines real-time Speech-to-Text, LLM reasoning, and expressive Text-to-Speech into a seamless conversational experience.

Speak naturally. Interrupt anytime. Switch voices. Change personas.

voice agents built  fully using open source models hosted and orchestrated locally.

<br>

### Overview

This project integrates streaming STT, an LLM, and real-time TTS to create a responsive voice-based AI system. The application supports multiple voices and domain-specific personas, including a production-style e-commerce agent.

The system is designed to feel conversational rather than transactional.



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







