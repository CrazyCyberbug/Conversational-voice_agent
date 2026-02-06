#!/usr/bin/env bash
set -e

echo "==== Updating system ===="
sudo apt-get update

echo "==== Installing system dependencies ===="
sudo apt-get install -y \
  zstd \
  pciutils \
  portaudio19-dev \
  curl \
  git

echo "==== Installing Ollama ===="
curl -fsSL https://ollama.com/install.sh | sh

echo "==== Starting Ollama server (background) ===="
ollama serve &
sleep 5

echo "==== Pulling model from Hugging Face via Ollama ===="
ollama pull "https://huggingface.co/ikawrakow/open-hermes-2.5-mistral-7b-quantized-gguf"


echo "==== Installing Python dependencies ===="
python3.10 -m pip install --upgrade pip
cd Conversational-voice_agent
python3.10 -m pip install -r requirements.txt

echo "==== Forcing specific dependency versions ===="
python3.10 -m pip install --force-reinstall transformers==4.36.2
python3.10 -m pip install --force-reinstall "numpy<2.0"
python3.10 -m pip install --force-reinstall --no-cache-dir thinc spacy
python3.10 -m pip install deepspeed
python3.10 -m pip install pyngrok

echo "==== Setup complete ===="
