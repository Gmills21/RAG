#!/usr/bin/env bash
set -euo pipefail

# preflight.sh
# Pre-flight checks before launching the Support Knowledge Bot

echo "=== Support Knowledge Bot - Preflight Checks ==="
echo ""

CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

# Check 1: Docker installed
echo "[1/9] Checking for Docker..."
if command -v docker &> /dev/null; then
    echo "  ✓ Docker found"
    ((CHECKS_PASSED++))
else
    echo "  ✗ Docker not found"
    echo "    Install from: https://docs.docker.com/get-docker/"
    ((CHECKS_FAILED++))
fi

# Check 2: Docker daemon running
echo "[2/9] Checking Docker daemon..."
if docker info &> /dev/null; then
    echo "  ✓ Docker daemon is running"
    ((CHECKS_PASSED++))
else
    echo "  ✗ Docker daemon is not running"
    echo "    Start Docker Desktop or run: sudo systemctl start docker"
    ((CHECKS_FAILED++))
fi

# Check 3: Docker Compose available
echo "[3/9] Checking for Docker Compose..."
if docker compose version &> /dev/null; then
    echo "  ✓ Docker Compose found"
    ((CHECKS_PASSED++))
else
    echo "  ✗ Docker Compose not found"
    echo "    Update Docker to include Compose V2"
    ((CHECKS_FAILED++))
fi

# Check 4: Ollama command
echo "[4/9] Checking for Ollama..."
if command -v ollama &> /dev/null; then
    echo "  ✓ Ollama command found"
    ((CHECKS_PASSED++))
else
    echo "  ✗ Ollama not found"
    echo "    Run: ./scripts/setup_ollama.sh"
    ((CHECKS_FAILED++))
fi

# Check 5: Ollama server reachable
echo "[5/9] Checking Ollama server..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "  ✓ Ollama server is reachable"
    ((CHECKS_PASSED++))
else
    echo "  ✗ Ollama server is not reachable"
    echo "    Start Ollama: 'ollama serve' or open Ollama app"
    ((CHECKS_FAILED++))
fi

# Check 6: Required Ollama models
echo "[6/9] Checking Ollama models..."
MODELS_INSTALLED=true
for model in "qwen3:4b" "qwen3:1.7b" "nomic-embed-text"; do
    if ollama list 2>/dev/null | grep -q "$model"; then
        echo "  ✓ Model $model installed"
    else
        echo "  ✗ Model $model not installed"
        MODELS_INSTALLED=false
    fi
done

if [ "$MODELS_INSTALLED" = true ]; then
    ((CHECKS_PASSED++))
else
    echo "    Run: ./scripts/setup_ollama.sh"
    ((CHECKS_FAILED++))
fi

# Check 7: Port 7860 availability
echo "[7/9] Checking port 7860..."
if lsof -i :7860 &> /dev/null || netstat -tuln 2>/dev/null | grep -q ":7860"; then
    echo "  ⚠ Port 7860 is already in use"
    echo "    Stop the existing service or change KOTAEMON_PORT in .env"
    ((WARNINGS++))
else
    echo "  ✓ Port 7860 is available"
    ((CHECKS_PASSED++))
fi

# Check 8: Sample data exists
echo "[8/9] Checking sample data..."
if [ -d "sample-data/support" ] && [ "$(ls -A sample-data/support 2>/dev/null)" ]; then
    echo "  ✓ Sample data directory exists and has files"
    ((CHECKS_PASSED++))
else
    echo "  ✗ Sample data directory is missing or empty"
    echo "    Sample data should be in sample-data/support/"
    ((CHECKS_FAILED++))
fi

# Check 9: Docker Compose config valid
echo "[9/9] Validating Docker Compose config..."
if docker compose config > /dev/null 2>&1; then
    echo "  ✓ Docker Compose config is valid"
    ((CHECKS_PASSED++))
else
    echo "  ✗ Docker Compose config is invalid"
    echo "    Run: docker compose config"
    ((CHECKS_FAILED++))
fi

echo ""
echo "=== Preflight Summary ==="
echo "Checks passed: $CHECKS_PASSED"
echo "Checks failed: $CHECKS_FAILED"
echo "Warnings: $WARNINGS"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo "✓ PREFLIGHT PASS: Ready to run docker compose up -d"
    echo ""
    echo "Next command:"
    echo "  docker compose up -d"
    echo ""
    exit 0
else
    echo "✗ PREFLIGHT FAIL: Fix the issues above before continuing"
    echo ""
    exit 1
fi
