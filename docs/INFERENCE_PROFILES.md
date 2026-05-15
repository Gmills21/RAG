# Inference profiles

Inference is selected by **profile**, not hard-coded to Ollama. YAML examples
live in [`config/inference/`](../config/inference/). UI copy-paste steps are in
[docs/KOTAEMON_MODEL_SETUP.md](KOTAEMON_MODEL_SETUP.md).

## Clean Vision

- Use `dev-ollama` for personal testing, offline development, and private rehearsal.
- Use `demo-hosted` for prospect demos because it must feel fast and reliable.
- Use `pilot-hosted` for paid pilots by default, on a dedicated single-customer deployment.
- Use `pilot-private-gpu` only when the customer forbids hosted inference and the GPU host can meet the same latency expectation.

Do not sell laptop Ollama latency as production behavior.

## Profile Summary

| Profile | When | Chat LLM | Embeddings | Base URL |
|---------|------|----------|------------|----------|
| `dev-ollama` | Founder laptop, personal testing | `qwen3:4b` | `nomic-embed-text` | `http://host.docker.internal:11434/v1/` |
| `demo-hosted` | Prospect demos, speed proof | `gpt-4o-mini` or approved equivalent | `text-embedding-3-small` or approved equivalent | `https://api.openai.com/v1/` or Azure/customer endpoint |
| `pilot-hosted` | First paid pilots, default | same as demo-hosted | same | Customer-approved hosted endpoint |
| `pilot-private-gpu` | Customer forbids hosted inference | 8B+ model on GPU host | local/private embed model | `http://host.docker.internal:11434/v1/` when the model server runs on the VPS host |

## Defaults

- **Personal testing:** `dev-ollama` - no paid API required, no production latency promise.
- **Demos and paid pilots:** `demo-hosted` / `pilot-hosted` - hosted APIs are the default product path.
- **Private production exception:** `pilot-private-gpu` - only after the customer rejects hosted inference and the GPU path is tested.

## Environment Variables

Set in `.env` or the deployment environment. Never commit real keys.

```bash
# dev-ollama (optional; Ollama ignores key value)
OLLAMA_API_KEY=ollama

# demo-hosted / pilot-hosted
OPENAI_API_KEY=sk-...

# Azure OpenAI alternative
# AZURE_OPENAI_ENDPOINT=https://YOUR_RESOURCE.openai.azure.com/
# AZURE_OPENAI_API_KEY=...
```

See [`.env.example`](../.env.example) for commented placeholders.

## Switching Profiles

1. Choose the profile YAML under `config/inference/`.
2. Apply LLM and embedding values in Kotaemon **Settings -> Resources**.
3. If the embedding model changed, re-index all documents.
4. Start a new conversation in Kotaemon after changing models.
5. Re-run the standard demo/eval questions before using the profile with a customer.

## Speed Target

- `demo-hosted` and `pilot-hosted`: cited live query **< 30s p95**.
- `pilot-private-gpu`: must meet the same production-speed target before it is sold as a pilot path.
- `dev-ollama`: best-effort only.

Until an automated benchmark script exists in this repo, time the standard demo
questions manually before external demos and record the result in the pilot
notes.
