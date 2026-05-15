# Kotaemon Model Setup

Configure Kotaemon **Resources** from an inference profile. The clean product
vision is:

- `dev-ollama` is for personal testing and local development.
- `demo-hosted` is for prospect demos.
- `pilot-hosted` is the default paid-pilot path.
- `pilot-private-gpu` is an exception for customers that forbid hosted inference.

Do not sell laptop Ollama latency as production behavior.

## Source Of Truth

- Profile YAML: [`config/inference/`](../config/inference/)
- Profile selection and env vars: [docs/INFERENCE_PROFILES.md](INFERENCE_PROFILES.md)

## Where To Configure

1. Open the app.
2. Go to **Settings -> Resources** or the model/LLM configuration panel.
3. Add or edit resources using vendor **ChatOpenAI**.
4. Configure one LLM resource and one embedding resource.
5. Set both as active for the collection you are using.
6. Save, then start a new conversation after any model change.

Values below match the example YAML files in `config/inference/`.

## Profile 1: `dev-ollama` For Personal Testing

When: local laptop testing, offline development, private rehearsal.

Example file: [config/inference/dev-ollama.example.yml](../config/inference/dev-ollama.example.yml)

LLM resource:

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://host.docker.internal:11434/v1/
model: qwen3:4b
```

Embedding resource:

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://host.docker.internal:11434/v1/
model: nomic-embed-text
```

Important:

- From inside Docker, use `http://host.docker.internal:11434/v1/`, not `http://localhost:11434/v1/`.
- Pull models first with `./scripts/setup_ollama.sh`.
- Latency is best-effort. This profile is not for prospect demos or paid pilots.

## Profile 2: `demo-hosted` For Prospect Demos

When: external prospect demos where speed and reliability matter.

Example file: [config/inference/demo-hosted.example.yml](../config/inference/demo-hosted.example.yml)

Prerequisite:

```bash
OPENAI_API_KEY=sk-your-key-here
```

LLM resource:

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: gpt-4o-mini
```

Embedding resource:

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: text-embedding-3-small
```

Pre-index `sample-data/support/*` before the live demo. Until an automated
benchmark exists in this repo, time the standard demo questions manually and do
not run a prospect call if latency is visibly poor.

Azure OpenAI is acceptable when the endpoint and deployment are approved; use
the deployment URL and model name from that tenant.

## Profile 3: `pilot-hosted` For Paid Pilots

When: first paid pilots on a dedicated single-customer deployment.

Example file: [config/inference/pilot-hosted.example.yml](../config/inference/pilot-hosted.example.yml)

Use the same resource shape as `demo-hosted`, unless the customer requires an
approved Azure or other OpenAI-compatible endpoint. Disclose that user questions
and retrieved source chunks are sent to the configured hosted inference provider.
See [docs/DATA_HANDLING.md](DATA_HANDLING.md).

This is the default production-speed path.

## Profile 4: `pilot-private-gpu` When Hosted Inference Is Forbidden

When: the customer forbids hosted inference and a private GPU deployment can
meet the same speed target.

Example file: [config/inference/pilot-private-gpu.example.yml](../config/inference/pilot-private-gpu.example.yml)

LLM resource when the model server runs on the VPS host and Kotaemon runs in Docker:

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://host.docker.internal:11434/v1/
model: qwen3:8b
```

Embedding resource:

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://host.docker.internal:11434/v1/
model: nomic-embed-text
```

If the model server runs as a Docker service, use that service DNS name instead
of `host.docker.internal`. Do not use `127.0.0.1` from inside the Kotaemon
container unless the model server is in the same container.

## Operational Rules

### Re-index When Changing Embeddings

Embeddings are model-specific. If you switch profiles or change the embedding
model:

1. Update the embedding resource in Kotaemon.
2. Re-upload or re-index all documents in the collection.
3. Start a new conversation.

### Keep Production Speed Honest

| Profile | Sold to customers? | Speed expectation |
|---------|--------------------|-------------------|
| `dev-ollama` | No | Best-effort only |
| `demo-hosted` | Yes | < 30s p95 cited query |
| `pilot-hosted` | Yes | < 30s p95 cited query |
| `pilot-private-gpu` | Yes, only when required | Must pass the same target before use |

### Reduce Expensive Retrieval Features On Weak Hardware

On `dev-ollama` or undersized private GPU hosts, reduce heavy LLM reranking if
responses are too slow. Prefer curated docs and clean retrieval over expensive
reranking passes.

## Quick Profile Picker

| I am... | Use profile | Config file |
|---------|-------------|-------------|
| Testing locally on my laptop | `dev-ollama` | `dev-ollama.example.yml` |
| Running a prospect demo | `demo-hosted` | `demo-hosted.example.yml` |
| Running a paid pilot | `pilot-hosted` | `pilot-hosted.example.yml` |
| Running a pilot where hosted inference is forbidden | `pilot-private-gpu` | `pilot-private-gpu.example.yml` |

## Related Docs

- [docs/LOCAL_SETUP.md](LOCAL_SETUP.md) - local bootstrap for `dev-ollama`
- [docs/INFERENCE_PROFILES.md](INFERENCE_PROFILES.md) - profile table and env vars
- [docs/DEMO_SCRIPT.md](DEMO_SCRIPT.md) - demo flow
- [docs/PILOT_DEPLOYMENT.md](PILOT_DEPLOYMENT.md) - VPS pilot deployment
