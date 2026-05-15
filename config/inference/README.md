# Inference profiles

Source of truth for LLM and embedding settings used in Kotaemon **Resources**.

| File | Profile | Use |
|------|---------|-----|
| `dev-ollama.example.yml` | `dev-ollama` | Local development on laptop (Ollama on host) |
| `demo-hosted.example.yml` | `demo-hosted` | Prospect demos; SLA target &lt; 30s p95 |
| `pilot-hosted.example.yml` | `pilot-hosted` | First paid pilots (default) |
| `pilot-private-gpu.example.yml` | `pilot-private-gpu` | Customer forbids cloud LLM; GPU VPS |

Copy values into Kotaemon **Settings → Resources** as **ChatOpenAI** vendor entries. See [docs/KOTAEMON_MODEL_SETUP.md](../../docs/KOTAEMON_MODEL_SETUP.md) for UI steps and [docs/INFERENCE_PROFILES.md](../../docs/INFERENCE_PROFILES.md) for profile selection.

**Rules:**

- Never commit API keys. Use `.env` or host secrets.
- Re-index all documents when you change the **embedding** model.
- `dev-ollama` is dev-only — do not sell laptop CPU latency as production behavior.
