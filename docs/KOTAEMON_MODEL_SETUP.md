# Kotaemon model setup

Configure Kotaemon **Resources** from an **inference profile**. Do not rely on tribal knowledge.

**Source of truth:**

- Profile YAML: [`config/inference/`](../config/inference/)
- Profile selection and env vars: [docs/INFERENCE_PROFILES.md](INFERENCE_PROFILES.md)

**Default product path:** Demos and paid pilots use **`demo-hosted`** or **`pilot-hosted`** (hosted OpenAI/Azure). **`dev-ollama`** is for local development only — not for prospect demos or production pilots.

---

## Where to configure in Kotaemon

1. Open the app (local: `http://localhost:7860`).
2. Go to **Settings → Resources** (or the model / LLM configuration panel).
3. Add or edit resources using vendor **ChatOpenAI** (OpenAI-compatible API).
4. Create **two** active resources per profile:
   - **LLM** (chat / completion)
   - **Embeddings** (indexing and retrieval)
5. Set both as the active defaults for the collection you are using.
6. Save, then start a **new conversation** after any model change.

Values below match the example YAML files in `config/inference/`.

---

## Profile 1: `dev-ollama` (development only)

**When:** Local laptop development. No paid API keys.

**Example file:** [config/inference/dev-ollama.example.yml](../config/inference/dev-ollama.example.yml)

### LLM resource

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://host.docker.internal:11434/v1/
model: qwen3:4b
```

Fallback for faster iteration: `qwen3:1.7b` (same `base_url`).

### Embedding resource

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://host.docker.internal:11434/v1/
model: nomic-embed-text
```

### Important

- From **inside Docker**, use `http://host.docker.internal:11434/v1/` — **not** `http://localhost:11434/v1/`.
- Pull models first: `./scripts/setup_ollama.sh`
- Latency on CPU laptop is **best-effort**. Do **not** present this as demo or pilot performance.

---

## Profile 2: `demo-hosted` (prospect demos)

**When:** External prospect demos. Required for SLA proof (&lt; 30s cited query p95).

**Example file:** [config/inference/demo-hosted.example.yml](../config/inference/demo-hosted.example.yml)

### Prerequisites

```bash
# In .env (do not commit)
OPENAI_API_KEY=sk-your-key-here
```

Pre-index `sample-data/support/*` before the live demo. Run `./scripts/benchmark_query_sla.sh` with the demo-hosted profile.

### LLM resource

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: gpt-4o-mini
```

### Embedding resource

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: text-embedding-3-small
```

### Azure OpenAI alternative

Use your Azure deployment URL as `base_url` and the deployment name as `model`. Set `AZURE_OPENAI_API_KEY` and endpoint per your tenant. See commented notes in `demo-hosted.example.yml`.

---

## Profile 3: `pilot-hosted` (first paid pilots — default)

**When:** Dedicated single-customer VPS pilot. Same models as `demo-hosted` unless the customer supplies an approved endpoint.

**Example file:** [config/inference/pilot-hosted.example.yml](../config/inference/pilot-hosted.example.yml)

### LLM resource

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: gpt-4o-mini
```

### Embedding resource

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: text-embedding-3-small
```

Use a **customer-approved** `base_url` when contract or security review requires it. Disclose that retrieved chunks may be sent to the cloud LLM — see [docs/DATA_HANDLING.md](DATA_HANDLING.md).

---

## Profile 4: `pilot-private-gpu` (no cloud LLM)

**When:** Customer forbids cloud LLM; Ollama (or vLLM) runs on a **GPU VPS** with the app.

**Example file:** [config/inference/pilot-private-gpu.example.yml](../config/inference/pilot-private-gpu.example.yml)

### LLM resource

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://127.0.0.1:11434/v1/
model: qwen3:8b
```

Replace `qwen3:8b` with the instruct model you deploy on the GPU (8B+ recommended).

### Embedding resource

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://127.0.0.1:11434/v1/
model: nomic-embed-text
```

On a VPS, `127.0.0.1` is correct when Ollama runs on the **same host** as Kotaemon (not `host.docker.internal`).

---

## Operational rules (all profiles)

### Re-index when changing embedding model

Embeddings are model-specific. If you switch profiles or change the embedding model (e.g. `nomic-embed-text` → `text-embedding-3-small`):

1. Update the embedding resource in Kotaemon.
2. **Re-upload or re-index** all documents in the collection.
3. Old vectors are not compatible with the new model.

### Disable heavy LLM reranking on weak hardware

On `dev-ollama` or small CPU/GPU hosts, turn off or reduce **LLM reranking** in Kotaemon retrieval settings if responses are too slow. Prefer hybrid retrieval defaults and curated docs over expensive rerank passes.

### Start a new conversation after model change

After changing LLM or embedding resources, **start a new chat** in Kotaemon. Existing threads may reference prior model behavior or stale context.

### Do not sell Ollama-on-laptop as production latency

| Profile | Sold to customers? |
|---------|------------------|
| `dev-ollama` | No — dev only |
| `demo-hosted` | Yes — default for demos |
| `pilot-hosted` | Yes — default for paid pilots |
| `pilot-private-gpu` | Yes — when cloud LLM is forbidden |

---

## Quick profile picker

| I am… | Use profile | Config file |
|-------|-------------|-------------|
| Building locally on my laptop | `dev-ollama` | `dev-ollama.example.yml` |
| Running a prospect demo | `demo-hosted` | `demo-hosted.example.yml` |
| Running a paid pilot on a VPS | `pilot-hosted` | `pilot-hosted.example.yml` |
| Pilot on VPS, no cloud LLM | `pilot-private-gpu` | `pilot-private-gpu.example.yml` |

---

## Related docs

- [docs/LOCAL_SETUP.md](LOCAL_SETUP.md) — full local bootstrap (dev-ollama)
- [docs/INFERENCE_PROFILES.md](INFERENCE_PROFILES.md) — profile table and env vars
- [docs/DEMO_SCRIPT.md](DEMO_SCRIPT.md) — demo flow (demo-hosted)
- [docs/PILOT_DEPLOYMENT.md](PILOT_DEPLOYMENT.md) — VPS pilot deployment
