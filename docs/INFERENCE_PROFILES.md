# Inference profiles

Inference is selected by **profile**, not hard-coded to Ollama. YAML examples live in [`config/inference/`](../config/inference/). UI copy-paste steps are in [docs/KOTAEMON_MODEL_SETUP.md](KOTAEMON_MODEL_SETUP.md).

## Profile summary

| Profile | When | Chat LLM | Embeddings | Base URL |
|---------|------|----------|------------|----------|
| `dev-ollama` | Founder laptop, offline dev | `qwen3:4b` | `nomic-embed-text` | `http://host.docker.internal:11434/v1/` |
| `demo-hosted` | Prospect demos, SLA proof | `gpt-4o-mini` | `text-embedding-3-small` | `https://api.openai.com/v1/` (or Azure) |
| `pilot-hosted` | First paid pilots (default) | same as demo-hosted | same | Customer-approved endpoint |
| `pilot-private-gpu` | No cloud LLM | 8B+ on GPU VPS | local embed model | `http://127.0.0.1:11434/v1/` on VPS |

## Defaults

- **Development:** `dev-ollama` — no paid API required.
- **Demos and paid pilots:** `demo-hosted` / `pilot-hosted` — **hosted APIs are the default product path.** Do not sell laptop `dev-ollama` latency as production behavior.

## Environment variables

Set in `.env` (never commit real keys):

```bash
# dev-ollama (optional; Ollama ignores key value)
OLLAMA_API_KEY=ollama

# demo-hosted / pilot-hosted
OPENAI_API_KEY=sk-...

# Azure OpenAI (optional alternative)
# AZURE_OPENAI_ENDPOINT=https://YOUR_RESOURCE.openai.azure.com/
# AZURE_OPENAI_API_KEY=...
```

See [`.env.example`](../.env.example) for commented placeholders.

## Switching profiles

1. Choose the profile YAML under `config/inference/`.
2. Apply LLM + embedding values in Kotaemon **Settings → Resources** ([KOTAEMON_MODEL_SETUP.md](KOTAEMON_MODEL_SETUP.md)).
3. If the **embedding model** changed, **re-index** all documents.
4. Start a **new conversation** in Kotaemon after changing models.

## SLA

- `demo-hosted` and `pilot-hosted`: cited live query **&lt; 30s p95** — run `./scripts/benchmark_query_sla.sh` before external demos.
- `dev-ollama`: best-effort only.
