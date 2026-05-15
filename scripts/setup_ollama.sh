#!/usr/bin/env bash
set -euo pipefail

# setup_ollama.sh
# Installs and configures Ollama with required models for the Support Knowledge Bot MVP

echo "=== Ollama Setup for Support Knowledge Bot ==="
echo ""

# Step 1: Check if ollama command exists
if ! command -v ollama &> /dev/null; then
    echo "ERROR: ollama command not found"
    echo ""
    echo "Please install Ollama first:"
    echo "  - macOS/Linux: curl -fsSL https://ollama.com/install.sh | sh"
    echo "  - Or visit: https://ollama.com/download"
    echo ""
    exit 1
fi

echo "OK: Ollama command found"
echo ""

# Step 2: Check if Ollama server is running
echo "Checking Ollama server..."
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "ERROR: Ollama server is not responding at http://localhost:11434"
    echo ""
    echo "Please start Ollama:"
    echo "  - macOS: Open the Ollama desktop app"
    echo "  - Linux: Run 'ollama serve' in another terminal"
    echo ""
    exit 1
fi

echo "OK: Ollama server is running"
echo ""

# Step 3: Pull required models
echo "Pulling required models (this may take several minutes)..."
echo ""

echo "1/3 Pulling qwen3:4b (primary LLM, ~2.3 GB)..."
if ! ollama pull qwen3:4b; then
    echo "ERROR: Failed to pull qwen3:4b"
    exit 1
fi
echo "OK: qwen3:4b installed"
echo ""

echo "2/3 Pulling qwen3:1.7b (low-resource fallback LLM, ~1.0 GB)..."
if ! ollama pull qwen3:1.7b; then
    echo "ERROR: Failed to pull qwen3:1.7b"
    exit 1
fi
echo "OK: qwen3:1.7b installed"
echo ""

echo "3/3 Pulling nomic-embed-text (embedding model, ~274 MB)..."
if ! ollama pull nomic-embed-text; then
    echo "ERROR: Failed to pull nomic-embed-text"
    exit 1
fi
echo "OK: nomic-embed-text installed"
echo ""

# Step 4: List installed models
echo "=== Installed Models ==="
ollama list
echo ""

# Step 5: Print configuration instructions
echo "=== Kotaemon Configuration Values ==="
echo ""
echo "Use these values when configuring Kotaemon:"
echo ""
echo "LLM Configuration:"
echo "  - Provider/Type: OpenAI-compatible (or OpenAI)"
echo "  - API Key: ollama"
echo "  - Base URL: http://host.docker.internal:11434/v1/"
echo "  - Model: qwen3:4b"
echo ""
echo "Embedding Configuration:"
echo "  - Provider/Type: OpenAI-compatible (or OpenAI)"
echo "  - API Key: ollama"
echo "  - Base URL: http://host.docker.internal:11434/v1/"
echo "  - Model: nomic-embed-text"
echo ""
echo "Low-Resource Fallback LLM:"
echo "  - Model: qwen3:1.7b"
echo "  - (Use if qwen3:4b is too slow on your machine)"
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/preflight.sh"
echo "  2. Run: docker compose up -d"
echo "  3. Open: http://localhost:7860"
echo ""
