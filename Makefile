# Makefile for Support Knowledge Bot MVP

.PHONY: help ollama smoke preflight up down logs reset-data

help:
	@echo "Support Knowledge Bot MVP - Available Commands:"
	@echo ""
	@echo "  make help       - Show this help message"
	@echo "  make ollama     - Run Ollama setup script"
	@echo "  make smoke      - Run Ollama smoke test"
	@echo "  make preflight  - Run preflight checks"
	@echo "  make up         - Start Docker Compose services"
	@echo "  make down       - Stop Docker Compose services"
	@echo "  make logs       - Follow Kotaemon logs"
	@echo "  make reset-data - Reset local data"

ollama:
	./scripts/setup_ollama.sh

smoke:
	./scripts/smoke_test_ollama.sh

preflight:
	./scripts/preflight.sh

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f kotaemon

reset-data:
	./scripts/reset_local_data.sh
