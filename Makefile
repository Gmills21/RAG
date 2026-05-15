# Makefile for Support Knowledge Bot MVP
# Simple shortcuts for common operations

.PHONY: help ollama smoke preflight up down logs restart reset-data clean

# Default target
help:
	@echo "Support Knowledge Bot - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make ollama       - Install and configure Ollama models"
	@echo "  make smoke        - Test Ollama chat and embeddings"
	@echo "  make preflight    - Run all preflight checks"
	@echo ""
	@echo "Runtime:"
	@echo "  make up           - Start Kotaemon in Docker"
	@echo "  make down         - Stop Kotaemon"
	@echo "  make restart      - Restart Kotaemon"
	@echo "  make logs         - Follow Kotaemon logs"
	@echo ""
	@echo "Maintenance:"
	@echo "  make reset-data   - Reset local app data (requires confirmation)"
	@echo "  make clean        - Stop containers and remove volumes"
	@echo ""

# Setup targets
ollama:
	@./scripts/setup_ollama.sh

smoke:
	@./scripts/smoke_test_ollama.sh

preflight:
	@./scripts/preflight.sh

# Runtime targets
up:
	@docker compose up -d
	@echo ""
	@echo "Kotaemon is starting..."
	@echo "Access at: http://localhost:7860"
	@echo ""
	@echo "To view logs: make logs"

down:
	@docker compose down

restart:
	@docker compose restart
	@echo "Kotaemon restarted"

logs:
	@docker compose logs -f kotaemon

# Maintenance targets
reset-data:
	@./scripts/reset_local_data.sh

clean:
	@echo "Stopping containers and removing volumes..."
	@docker compose down -v
	@echo "Done"
