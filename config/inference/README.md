# Inference Profiles

Source of truth for LLM and embedding settings used in Kotaemon **Resources**.

| File | Profile | Use |
|------|---------|-----|
| `dev-ollama.example.yml` | `dev-ollama` | Personal/local testing on laptop |
| `demo-hosted.example.yml` | `demo-hosted` | Prospect demos; target < 30s p95 cited query |
| `pilot-hosted.example.yml` | `pilot-hosted` | First paid pilots, default production-speed path |
| `pilot-private-gpu.example.yml` | `pilot-private-gpu` | Customer forbids hosted inference; GPU VPS must meet production speed |

Copy values into Kotaemon **Settings -> Resources** as **ChatOpenAI** vendor
entries. See [docs/KOTAEMON_MODEL_SETUP.md](../../docs/KOTAEMON_MODEL_SETUP.md)
for UI steps and [docs/INFERENCE_PROFILES.md](../../docs/INFERENCE_PROFILES.md)
for profile selection.

Rules:

- Never commit API keys. Use `.env` or host secrets.
- Re-index all documents when you change the embedding model.
- `dev-ollama` is dev-only; do not sell laptop CPU latency as production behavior.
- Demos and paid pilots use `demo-hosted` or `pilot-hosted` unless a customer specifically requires private GPU inference.
