#!/usr/bin/env bash
set -euo pipefail

# Ollama setup script for Support Knowledge Bot MVP
# This script verifies Ollama is installed, pulls required models, and provides config values

echo "=========================================="
echo "Support Knowledge Bot - Ollama Setup"
echo "=========================================="
echo ""

# Check if ollama command exists
if ! command -v ollama >/dev/null 2>&1; then
    echo "ERROR: ollama command not found."
    echo ""
    echo "Please install Ollama first:"
    echo "  - macOS/Linux: https://ollama.ai/download"
    echo "  - Or visit: https://github.com/ollama/ollama"
    echo ""
    echo "After installation, start the Ollama service and run this script again."
    exit 1
fi

echo "✓ Ollama command found"
echo ""

# Check if Ollama server is running
echo "Checking Ollama server status..."
if ! curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "ERROR: Ollama server is not responding at http://localhost:11434"
    echo ""
    echo "Please start the Ollama server:"
    echo "  - If you have the Ollama desktop app: start the app"
    echo "  - Or run in a terminal: ollama serve"
    echo ""
    echo "After starting the server, run this script again."
    exit 1
fi

echo "✓ Ollama server is running"
echo ""

# Pull required models
echo "=========================================="
echo "Pulling required models..."
echo "=========================================="
echo ""
echo "This may take several minutes depending on your connection."
echo ""

MODELS=(
    "qwen3:4b"
    "qwen3:1.7b"
    "nomic-embed-text"
)

for model in "${MODELS[@]}"; do
    echo "Pulling model: $model"
    if ollama pull "$model"; then
        echo "✓ Successfully pulled: $model"
    else
        echo "ERROR: Failed to pull model: $model"
        exit 1
    fi
    echo ""
done

# List all installed models
echo "=========================================="
echo "Installed Ollama models:"
echo "=========================================="
ollama list
echo ""

# Print Kotaemon configuration values
echo "=========================================="
echo "Kotaemon Configuration Values"
echo "=========================================="
echo ""
echo "Use these values when configuring Kotaemon resources/settings:"
echo ""
echo "LLM Configuration:"
echo "  Provider/Type: OpenAI-compatible (or OpenAI)"
echo "  API Key: ollama"
echo "  Base URL: http://host.docker.internal:11434/v1/"
echo "  Model: qwen3:4b"
echo ""
echo "Embedding Configuration:"
echo "  Provider/Type: OpenAI-compatible (or OpenAI)"
echo "  API Key: ollama"
echo "  Base URL: http://host.docker.internal:11434/v1/"
echo "  Model: nomic-embed-text"
echo ""
echo "Low-Resource Fallback LLM:"
echo "  Model: qwen3:1.7b"
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/preflight.sh"
echo "  2. Run: docker compose up -d"
echo "  3. Open: http://localhost:7860"
echo ""
