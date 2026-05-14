# Support Knowledge Bot MVP

## What This Is

This is a **wrapper and packaging repository** for a local-first SMB support knowledge bot MVP.

**We did not build the RAG engine.** This MVP uses:

- **Kotaemon** — for document QA, citations, and source preview
- **Ollama** — for local LLM (qwen3:4b) and embeddings (nomic-embed-text)

This repo provides:
- Docker-based setup
- Ollama model scripts
- Prompt packs for support teams
- Sample data for demos
- Customer onboarding guides

## What This Is Not

This is **not**:
- A custom RAG system
- A custom vector database
- A custom chat UI
- A SaaS platform
- An integration marketplace

## Quick Start

```bash
./scripts/setup_ollama.sh
./scripts/preflight.sh
docker compose up -d
open http://localhost:7860
```

Full setup instructions: see `docs/LOCAL_SETUP.md`

## Stack

- Base app: Kotaemon (OSS document QA)
- LLM: Ollama + qwen3:4b
- Embeddings: Ollama + nomic-embed-text
- Runtime: Docker
- Deployment: Local-first

## Documentation

See `docs/` folder for:
- Local setup guide
- Model configuration
- Customer onboarding
- Demo scripts
- Troubleshooting

## License

See `LICENSE_NOTES.md` for OSS attribution and licensing details.
