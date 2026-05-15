#!/usr/bin/env bash
set -euo pipefail

# Preflight checks script
# Verifies all dependencies and prerequisites before running the MVP

echo "🚦 Preflight Checks"
echo "==================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

# Check 1: Docker command exists
echo "Check 1: Docker command..."
if command -v docker > /dev/null 2>&1; then
    check_pass "Docker command is available"
else
    check_fail "Docker command not found"
    echo "  Install Docker: https://docs.docker.com/get-docker/"
fi
echo ""

# Check 2: Docker daemon is running
echo "Check 2: Docker daemon..."
if command -v docker > /dev/null 2>&1; then
    if docker info > /dev/null 2>&1; then
        check_pass "Docker daemon is running"
    else
        check_fail "Docker daemon is not running"
        echo "  Start Docker Desktop or run: sudo systemctl start docker"
    fi
else
    check_warn "Skipping (Docker not installed)"
fi
echo ""

# Check 3: Docker Compose availability
echo "Check 3: Docker Compose..."
if command -v docker > /dev/null 2>&1; then
    if docker compose version > /dev/null 2>&1; then
        check_pass "Docker Compose is available (docker compose)"
    elif command -v docker-compose > /dev/null 2>&1; then
        check_pass "Docker Compose is available (docker-compose)"
    else
        check_fail "Docker Compose not found"
        echo "  Install Docker Compose: https://docs.docker.com/compose/install/"
    fi
else
    check_warn "Skipping (Docker not installed)"
fi
echo ""

# Check 4: Ollama command exists
echo "Check 4: Ollama command..."
if command -v ollama > /dev/null 2>&1; then
    check_pass "Ollama command is available"
else
    check_fail "Ollama command not found"
    echo "  Install Ollama: https://ollama.ai/download"
fi
echo ""

# Check 5: Ollama server is reachable
echo "Check 5: Ollama server..."
if command -v ollama > /dev/null 2>&1; then
    if curl -s --max-time 3 http://localhost:11434/api/tags > /dev/null 2>&1; then
        check_pass "Ollama server is reachable"
    else
        check_fail "Ollama server is not reachable"
        echo "  Start Ollama: run 'ollama serve' or start Ollama Desktop app"
    fi
else
    check_warn "Skipping (Ollama not installed)"
fi
echo ""

# Check 6: Required Ollama models
echo "Check 6: Ollama models..."
if command -v ollama > /dev/null 2>&1 && curl -s --max-time 3 http://localhost:11434/api/tags > /dev/null 2>&1; then
    MODELS=$(ollama list 2>/dev/null || echo "")
    
    MODELS_MISSING=()
    
    if echo "$MODELS" | grep -q "qwen3:4b"; then
        check_pass "Model qwen3:4b is installed"
    else
        check_fail "Model qwen3:4b is missing"
        MODELS_MISSING+=("qwen3:4b")
    fi
    
    if echo "$MODELS" | grep -q "qwen3:1.7b"; then
        check_pass "Model qwen3:1.7b is installed"
    else
        check_warn "Model qwen3:1.7b is missing (optional low-resource fallback)"
        MODELS_MISSING+=("qwen3:1.7b")
    fi
    
    if echo "$MODELS" | grep -q "nomic-embed-text"; then
        check_pass "Model nomic-embed-text is installed"
    else
        check_fail "Model nomic-embed-text is missing"
        MODELS_MISSING+=("nomic-embed-text")
    fi
    
    if [ ${#MODELS_MISSING[@]} -gt 0 ]; then
        echo "  Pull missing models with:"
        echo "  ./scripts/setup_ollama.sh"
        echo "  or manually:"
        for model in "${MODELS_MISSING[@]}"; do
            echo "  ollama pull $model"
        done
    fi
else
    check_warn "Skipping (Ollama not available)"
fi
echo ""

# Check 7: Port 7860 availability
echo "Check 7: Port 7860 availability..."
PORT_IN_USE=false

# Try multiple methods to check port
if command -v ss > /dev/null 2>&1; then
    if ss -ltn | grep -q ":7860 "; then
        PORT_IN_USE=true
    fi
elif command -v netstat > /dev/null 2>&1; then
    if netstat -ln | grep -q ":7860 "; then
        PORT_IN_USE=true
    fi
elif command -v lsof > /dev/null 2>&1; then
    if lsof -i :7860 > /dev/null 2>&1; then
        PORT_IN_USE=true
    fi
fi

if [ "$PORT_IN_USE" = true ]; then
    check_warn "Port 7860 is already in use"
    echo "  Stop the process using port 7860 or use a different port"
    echo "  Find process: lsof -i :7860 or ss -ltnp | grep 7860"
else
    check_pass "Port 7860 is available"
fi
echo ""

# Check 8: Sample data exists
echo "Check 8: Sample data..."
if [ -d "sample-data/support" ]; then
    FILE_COUNT=$(find sample-data/support -type f | wc -l)
    if [ "$FILE_COUNT" -gt 0 ]; then
        check_pass "Sample data directory exists with $FILE_COUNT file(s)"
    else
        check_fail "Sample data directory is empty"
        echo "  Sample data should be created in Step 7"
    fi
else
    check_fail "Sample data directory not found: sample-data/support"
    echo "  Create sample data in Step 7 of the PDR"
fi
echo ""

# Summary
echo "==================="
echo "Summary: ${PASS_COUNT} passed, ${WARN_COUNT} warnings, ${FAIL_COUNT} failed"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ PREFLIGHT PASS${NC}"
    echo ""
    echo "Ready to run:"
    echo "  docker compose up -d"
    echo ""
    if [ "$WARN_COUNT" -gt 0 ]; then
        echo "Note: There are warnings, but they are not blocking."
    fi
    exit 0
else
    echo -e "${RED}✗ PREFLIGHT FAIL${NC}"
    echo ""
    echo "Please fix the ${FAIL_COUNT} failed check(s) above before proceeding."
    echo ""
    echo "Common fixes:"
    echo "  - Install Docker: https://docs.docker.com/get-docker/"
    echo "  - Install Ollama: https://ollama.ai/download"
    echo "  - Start Ollama: ollama serve"
    echo "  - Pull models: ./scripts/setup_ollama.sh"
    echo ""
    exit 1
fi
