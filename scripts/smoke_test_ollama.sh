#!/usr/bin/env bash
set -euo pipefail

# smoke_test_ollama.sh
# Verifies that Ollama is fully functional for chat and embeddings

echo "=== Ollama Smoke Test ==="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Test 1: Check Ollama server is reachable
echo "Test 1/3: Checking Ollama server..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "PASS: Ollama server is reachable"
    ((PASS_COUNT++))
else
    echo "FAIL: Ollama server is not reachable at http://localhost:11434"
    ((FAIL_COUNT++))
fi
echo ""

# Test 2: Test chat completion
echo "Test 2/3: Testing chat completion with qwen3:4b..."
CHAT_RESPONSE=$(curl -s http://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "qwen3:4b",
        "messages": [{"role": "user", "content": "Say hello"}],
        "max_tokens": 10
    }')

if echo "$CHAT_RESPONSE" | grep -q '"content"'; then
    echo "PASS: Chat completion returned content"
    ((PASS_COUNT++))
else
    echo "FAIL: Chat completion did not return expected content"
    echo "Response: $CHAT_RESPONSE"
    ((FAIL_COUNT++))
fi
echo ""

# Test 3: Test embeddings
echo "Test 3/3: Testing embeddings with nomic-embed-text..."
EMBED_RESPONSE=$(curl -s http://localhost:11434/v1/embeddings \
    -H "Content-Type: application/json" \
    -d '{
        "model": "nomic-embed-text",
        "input": "test embedding"
    }')

if echo "$EMBED_RESPONSE" | grep -q '"embedding"'; then
    echo "PASS: Embeddings returned vector data"
    ((PASS_COUNT++))
else
    echo "FAIL: Embeddings did not return expected data"
    echo "Response: $EMBED_RESPONSE"
    ((FAIL_COUNT++))
fi
echo ""

# Summary
echo "=== Test Summary ==="
echo "PASSED: $PASS_COUNT/3"
echo "FAILED: $FAIL_COUNT/3"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "SUCCESS: All smoke tests passed"
    echo "Ollama is ready for use with Kotaemon"
    exit 0
else
    echo "FAILURE: Some smoke tests failed"
    echo "Please check Ollama installation and model availability"
    exit 1
fi
