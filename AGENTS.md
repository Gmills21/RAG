# AGENTS.md

## Project overview

This is a **documentation/planning repository** for a "Support Knowledge Bot" MVP — a wrapper around [Kotaemon](https://github.com/cinnamon/kotaemon) (document QA UI) and [Ollama](https://ollama.ai) (local LLM runtime). The codebase currently contains only design documents (PDR) in `Overview/`. The 23-step build plan in `Overview/finalized_local_first_support_kb_pdr.md` describes the full implementation to create.

The step-by-step commander workflow is in `Overview/prompts.md`.

## Cursor Cloud specific instructions

### Environment

- **Docker + Docker Compose V2** are required. Docker must be started with `sudo dockerd` before use (the VM runs inside a nested container). Use `sudo docker ...` or ensure the user is in the `docker` group.
- **Python 3.12** is available at `/usr/bin/python3`. No virtual environment or package manager lockfile exists yet; install Python deps directly with `pip install`.
- **Make 4.3** is available.
- **mdformat** is installed for markdown linting: `mdformat --check <file>`.
- **Ollama** is NOT installed in the Cloud VM and requires manual setup if needed for end-to-end testing. The PDR models (`qwen3:4b`, `qwen3:1.7b`, `nomic-embed-text`) require significant resources.
- Docker is configured with `fuse-overlayfs` storage driver and `iptables-legacy` for nested container compatibility.

### Key files

| File | Purpose |
|------|---------|
| `Overview/finalized_local_first_support_kb_pdr.md` | Full Product Design Requirements — source of truth for the 23-step build |
| `Overview/prompts.md` | Commander framework — step-by-step prompts for implementing the PDR |
| `Overview/README.md` | Stub README (to be replaced at Step 22) |

### Development workflow

The PDR prescribes a strict one-step-at-a-time workflow: plan → approve → implement → verify → fix → manual check → commit → next step. See `Overview/prompts.md` for the full prompt framework.

### Non-negotiables from the PDR

- Do NOT build custom RAG code. Wire together Kotaemon + Ollama + docs + scripts.
- Do NOT add paid LLM API requirements for the default path.
- Do NOT add Google Drive, Slack, Jira, Zendesk, or other API integrations in v0.
- Default LLM: `qwen3:4b` via Ollama. Default embeddings: `nomic-embed-text` via Ollama.
- Kotaemon Docker image: `ghcr.io/cinnamon/kotaemon:main-full` on port 7860.

### Running Docker in the Cloud VM

```bash
# Start the Docker daemon (needed once per session)
sudo dockerd &>/tmp/dockerd.log &
sleep 3

# All docker commands need sudo unless the user is in the docker group
sudo docker compose up -d
sudo docker compose down
```

### Linting

```bash
# Markdown formatting check
mdformat --check Overview/*.md
```
