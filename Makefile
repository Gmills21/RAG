# Makefile for Support Knowledge Bot MVP
# Simple shortcuts for common operations

.PHONY: help ollama smoke preflight up down logs reset-data

# Default target
help:
	@echo "Support Knowledge Bot - Makefile Commands"
	@echo "==========================================="
	@echo ""
	@echo "Setup & Testing:"
	@echo "  make ollama      - Pull required Ollama models (qwen3:4b, nomic-embed-text)"
	@echo "  make smoke       - Test Ollama chat and embeddings"
	@echo "  make preflight   - Run all prerequisite checks before starting"
	@echo ""
	@echo "Application:"
	@echo "  make up          - Start Kotaemon with docker compose"
	@echo "  make down        - Stop Kotaemon"
	@echo "  make logs        - View Kotaemon logs (follow mode)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make reset-data  - Reset local app data (requires confirmation)"
	@echo ""
	@echo "Quick start:"
	@echo "  1. make ollama"
	@echo "  2. make preflight"
	@echo "  3. make up"
	@echo "  4. Open http://localhost:7860"
	@echo ""

ollama:
	@echo "Pulling required Ollama models..."
	./scripts/setup_ollama.sh

smoke:
	@echo "Running Ollama smoke tests..."
	./scripts/smoke_test_ollama.sh

preflight:
	@echo "Running preflight checks..."
	./scripts/preflight.sh

up:
	@echo "Starting Kotaemon..."
	docker compose up -d
	@echo ""
	@echo "Kotaemon is starting. Access it at: http://localhost:7860"
	@echo "Run 'make logs' to view startup logs."

down:
	@echo "Stopping Kotaemon..."
	docker compose down

logs:
	@echo "Following Kotaemon logs (Ctrl+C to exit)..."
	docker compose logs -f kotaemon

reset-data:
	@echo "Resetting local app data..."
	./scripts/reset_local_data.sh
