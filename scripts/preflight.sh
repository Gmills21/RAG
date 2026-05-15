#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "Support Knowledge Bot - Preflight Checks"
echo "=========================================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
ISSUES=()

# Check 1: Docker installed
echo "Check 1: Docker installed..."
if command -v docker >/dev/null 2>&1; then
    echo "  ✓ PASS: Docker command found"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  ✗ FAIL: Docker not installed"
    ISSUES+=("Install Docker: https://docs.docker.com/get-docker/")
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Check 2: Docker daemon running
echo "Check 2: Docker daemon running..."
if docker info >/dev/null 2>&1; then
    echo "  ✓ PASS: Docker daemon is running"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  ✗ FAIL: Docker daemon is not running"
    ISSUES+=("Start Docker daemon or Docker Desktop app")
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Check 3: Docker Compose available
echo "Check 3: Docker Compose available..."
if docker compose version >/dev/null 2>&1; then
    echo "  ✓ PASS: Docker Compose is available"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  ✗ FAIL: Docker Compose not available"
    ISSUES+=("Install Docker Compose: https://docs.docker.com/compose/install/")
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Check 4: Ollama command installed
echo "Check 4: Ollama command installed..."
if command -v ollama >/dev/null 2>&1; then
    echo "  ✓ PASS: Ollama command found"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  ✗ FAIL: Ollama command not found"
    ISSUES+=("Install Ollama: https://ollama.ai/download or run ./scripts/setup_ollama.sh")
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Check 5: Ollama server reachable
echo "Check 5: Ollama server reachable..."
if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "  ✓ PASS: Ollama server is reachable"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  ✗ FAIL: Ollama server not reachable at localhost:11434"
    ISSUES+=("Start Ollama: run 'ollama serve' or start Ollama desktop app")
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Check 6: Required models installed
echo "Check 6: Required Ollama models installed..."
REQUIRED_MODELS=("qwen3:4b" "qwen3:1.7b" "nomic-embed-text")
MISSING_MODELS=()

if command -v ollama >/dev/null 2>&1; then
    for model in "${REQUIRED_MODELS[@]}"; do
        if ollama list 2>/dev/null | grep -q "^${model}"; then
            echo "  ✓ Model installed: $model"
        else
            echo "  ✗ Model missing: $model"
            MISSING_MODELS+=("$model")
        fi
    done
    
    if [ ${#MISSING_MODELS[@]} -eq 0 ]; then
        echo "  ✓ PASS: All required models installed"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  ✗ FAIL: Missing models: ${MISSING_MODELS[*]}"
        ISSUES+=("Pull missing models: run ./scripts/setup_ollama.sh")
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "  ⊘ SKIP: Ollama not installed"
fi

# Check 7: Port 7860 availability
echo "Check 7: Port 7860 availability..."
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :7860 >/dev/null 2>&1; then
        echo "  ⚠ WARNING: Port 7860 is already in use"
        ISSUES+=("Stop the process using port 7860, or docker compose down if Kotaemon is running")
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        echo "  ✓ PASS: Port 7860 is available"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tln 2>/dev/null | grep -q ":7860 "; then
        echo "  ⚠ WARNING: Port 7860 is already in use"
        ISSUES+=("Stop the process using port 7860, or docker compose down if Kotaemon is running")
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        echo "  ✓ PASS: Port 7860 is available"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
elif command -v ss >/dev/null 2>&1; then
    if ss -tln 2>/dev/null | grep -q ":7860 "; then
        echo "  ⚠ WARNING: Port 7860 is already in use"
        ISSUES+=("Stop the process using port 7860, or docker compose down if Kotaemon is running")
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        echo "  ✓ PASS: Port 7860 is available"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
else
    echo "  ⊘ SKIP: No port checking tool available (lsof/netstat/ss)"
fi

# Check 8: Sample data exists
echo "Check 8: Sample data directory..."
if [ -d "sample-data/support" ]; then
    FILE_COUNT=$(find sample-data/support -type f 2>/dev/null | wc -l)
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "  ✓ PASS: sample-data/support exists with $FILE_COUNT files"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  ✗ FAIL: sample-data/support exists but is empty"
        ISSUES+=("Add sample data files to sample-data/support/")
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "  ✗ FAIL: sample-data/support directory not found"
    ISSUES+=("Create sample-data/support directory with demo files")
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Final summary
echo ""
echo "=========================================="
echo "PREFLIGHT SUMMARY"
echo "=========================================="
echo "Passed:   $PASS_COUNT"
echo "Failed:   $FAIL_COUNT"
echo "Warnings: $WARN_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✓✓✓ PREFLIGHT PASS ✓✓✓"
    echo ""
    if [ $WARN_COUNT -gt 0 ]; then
        echo "Warnings detected (non-blocking):"
        for issue in "${ISSUES[@]}"; do
            echo "  - $issue"
        done
        echo ""
    fi
    echo "Ready to run: docker compose up -d"
    echo ""
    exit 0
else
    echo "✗✗✗ PREFLIGHT FAIL ✗✗✗"
    echo ""
    echo "Please fix these issues before running docker compose up:"
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""
    exit 1
fi
