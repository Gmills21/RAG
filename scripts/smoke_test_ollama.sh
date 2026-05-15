#!/usr/bin/env bash
set -euo pipefail

# Ollama smoke test script
# Verifies local chat and embeddings work before launching Kotaemon

OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://localhost:11434}"
CHAT_MODEL="${CHAT_MODEL:-qwen3:4b}"
EMBEDDING_MODEL="${EMBEDDING_MODEL:-nomic-embed-text}"

echo "🧪 Ollama Smoke Test"
echo "===================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

# Test 1: Check if Ollama server is reachable
echo "Test 1: Checking if Ollama server is reachable..."
if curl -s --max-time 5 "${OLLAMA_BASE_URL}/api/tags" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Ollama server is reachable at ${OLLAMA_BASE_URL}"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗ FAIL${NC}: Ollama server is not reachable at ${OLLAMA_BASE_URL}"
    echo "  Please ensure Ollama is running:"
    echo "  - Run 'ollama serve' in a terminal, or"
    echo "  - Start the Ollama desktop app"
    ((FAIL_COUNT++))
fi
echo ""

# Test 2: Check chat completion with qwen3:4b
echo "Test 2: Testing chat completion with ${CHAT_MODEL}..."
CHAT_RESPONSE=$(curl -s --max-time 30 "${OLLAMA_BASE_URL}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"${CHAT_MODEL}\",
        \"messages\": [{\"role\": \"user\", \"content\": \"Reply with just the word OK\"}],
        \"max_tokens\": 10,
        \"temperature\": 0
    }" 2>&1 || echo "CURL_ERROR")

# Check if curl failed
if echo "$CHAT_RESPONSE" | grep -q "CURL_ERROR"; then
    echo -e "${RED}✗ FAIL${NC}: Chat completion request failed (network error)"
    echo "  Could not connect to ${OLLAMA_BASE_URL}/v1/chat/completions"
    ((FAIL_COUNT++))
# Check for model not found error
elif echo "$CHAT_RESPONSE" | grep -qi "model.*not found\|does not exist\|pull.*model"; then
    echo -e "${RED}✗ FAIL${NC}: Model '${CHAT_MODEL}' not found"
    echo "  Please pull the model first:"
    echo "  ollama pull ${CHAT_MODEL}"
    ((FAIL_COUNT++))
# Check if response contains content
elif echo "$CHAT_RESPONSE" | grep -q '"content"'; then
    echo -e "${GREEN}✓ PASS${NC}: Chat completion returned content"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗ FAIL${NC}: Chat completion did not return expected content"
    echo "  Response: ${CHAT_RESPONSE:0:200}"
    ((FAIL_COUNT++))
fi
echo ""

# Test 3: Check embeddings with nomic-embed-text
echo "Test 3: Testing embeddings with ${EMBEDDING_MODEL}..."
EMBED_RESPONSE=$(curl -s --max-time 30 "${OLLAMA_BASE_URL}/v1/embeddings" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"${EMBEDDING_MODEL}\",
        \"input\": \"test embedding\"
    }" 2>&1 || echo "CURL_ERROR")

# Check if curl failed
if echo "$EMBED_RESPONSE" | grep -q "CURL_ERROR"; then
    echo -e "${RED}✗ FAIL${NC}: Embeddings request failed (network error)"
    echo "  Could not connect to ${OLLAMA_BASE_URL}/v1/embeddings"
    ((FAIL_COUNT++))
# Check for model not found error
elif echo "$EMBED_RESPONSE" | grep -qi "model.*not found\|does not exist\|pull.*model"; then
    echo -e "${RED}✗ FAIL${NC}: Model '${EMBEDDING_MODEL}' not found"
    echo "  Please pull the model first:"
    echo "  ollama pull ${EMBEDDING_MODEL}"
    ((FAIL_COUNT++))
# Check if response contains embedding data
elif echo "$EMBED_RESPONSE" | grep -q '"embedding"'; then
    echo -e "${GREEN}✓ PASS${NC}: Embeddings returned vector data"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗ FAIL${NC}: Embeddings did not return expected data"
    echo "  Response: ${EMBED_RESPONSE:0:200}"
    ((FAIL_COUNT++))
fi
echo ""

# Summary
echo "===================="
echo "Summary: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ All smoke tests passed!${NC}"
    echo "Ollama is ready for Kotaemon."
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    echo "Please fix the issues above before proceeding."
    exit 1
fi
