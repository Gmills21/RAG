#!/usr/bin/env bash
set -euo pipefail

echo "=== Ollama Smoke Test ==="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

echo "Check 1: Ollama server reachable..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✓ PASS: Ollama server is reachable"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Ollama server is not reachable"
    echo "  Make sure Ollama is running: ollama serve"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo ""
echo "Check 2: Chat completion with qwen3:4b..."
CHAT_RESPONSE=$(curl -s http://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "qwen3:4b",
        "messages": [{"role": "user", "content": "Say test"}],
        "max_tokens": 10
    }')

if echo "$CHAT_RESPONSE" | grep -q '"content"'; then
    echo "✓ PASS: Chat completion returned content"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Chat completion did not return content"
    echo "  Response: $CHAT_RESPONSE"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo ""
echo "Check 3: Embeddings with nomic-embed-text..."
EMBED_RESPONSE=$(curl -s http://localhost:11434/v1/embeddings \
    -H "Content-Type: application/json" \
    -d '{
        "model": "nomic-embed-text",
        "input": "test"
    }')

if echo "$EMBED_RESPONSE" | grep -q '"embedding"'; then
    echo "✓ PASS: Embeddings returned vector data"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Embeddings did not return vector data"
    echo "  Response: $EMBED_RESPONSE"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo ""
echo "=== Summary ==="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -eq 0 ]; then
    echo ""
    echo "✓ All smoke tests passed!"
    exit 0
else
    echo ""
    echo "✗ Some smoke tests failed"
    exit 1
fi
