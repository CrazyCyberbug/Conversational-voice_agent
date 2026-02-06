#!/usr/bin/env bash
set -e

# ---------- CONFIG ----------
LOG_DIR="$HOME/.setup_logs"
OLLAMA_LOG="$LOG_DIR/ollama.log"
mkdir -p "$LOG_DIR"

# ---------- SPINNER ----------
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while ps -p "$pid" > /dev/null 2>&1; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

run_step() {
  local msg="$1"
  shift
  echo "==== $msg ===="
  ("$@" >"$LOG_DIR/step.log" 2>&1) &
  spinner $!
  wait $!
  echo "✔ Done"
}

# ---------- STEPS ----------

run_step "Updating system" \
  sudo apt-get update -qq

run_step "Installing Python 3.10" \
  sudo apt-get install -y -qq \
    python3.10 \
    python3.10-venv \
    python3.10-dev

run_step "Installing pip" \
  bash -c "curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10"

run_step "Installing system dependencies" \
  sudo apt-get install -y -qq \
    zstd \
    pciutils \
    portaudio19-dev \
    curl \
    git

run_step "Installing Ollama" \
  bash -c "curl -fsSL https://ollama.com/install.sh | sh"

echo "==== Starting Ollama server (background) ===="
nohup ollama serve >"$OLLAMA_LOG" 2>&1 &
OLLAMA_PID=$!
echo "Ollama PID: $OLLAMA_PID"

# Wait until Ollama is responsive
echo "Waiting for Ollama to be ready..."
until ollama list >/dev/null 2>&1; do
  sleep 1
done
echo "✔ Ollama is ready"

run_step "Pulling model via Ollama" \
  ollama pull "https://huggingface.co/ikawrakow/open-hermes-2.5-mistral-7b-quantized-gguf"

run_step "Installing Python dependencies" \
  bash -c "
    python3.10 -m pip install -q --upgrade pip &&
    cd Conversational-voice_agent &&
    python3.10 -m pip install -q -r requirements.txt
  "

run_step "Forcing specific dependency versions" \
  bash -c "
    python3.10 -m pip install -q --force-reinstall transformers==4.36.2 &&
    python3.10 -m pip install -q --force-reinstall 'numpy<2.0' &&
    python3.10 -m pip install -q --force-reinstall --no-cache-dir thinc spacy &&
    python3.10 -m pip install -q deepspeed pyngrok
  "

echo "==== Setup complete ===="
echo "Ollama running in background (PID: $OLLAMA_PID)"
echo "Logs: $OLLAMA_LOG"
