# Local Setup Guide

Get the Support Knowledge Bot running on your laptop for development and internal testing. No VPS, VPN, reverse proxy, Caddy, customer domain, or customer infrastructure required.

> **Inference profile for this guide:** `dev-ollama` (local Ollama on your laptop).  
> **Not for demos or pilots.** External demos should use `demo-hosted`; paid pilots should use `pilot-hosted` unless private GPU is required. See [docs/INFERENCE_PROFILES.md](INFERENCE_PROFILES.md) and [docs/KOTAEMON_MODEL_SETUP.md](KOTAEMON_MODEL_SETUP.md).

---

## Prerequisites

Install these before starting:

| Tool | Version | Install |
|------|---------|---------|
| Docker Desktop | 4.x or later | https://www.docker.com/products/docker-desktop |
| Docker Compose | v2 (included with Docker Desktop) | Bundled |
| Ollama | latest | https://ollama.com/download |
| Git | any | https://git-scm.com |

**Check your prerequisites:**

```bash
docker --version
docker compose version
ollama --version
```

All three commands should return a version number. If any fail, install the missing tool before continuing.

---

## Step 1: Clone the repo

```bash
git clone https://github.com/Gmills21/RAG.git support-knowledge-bot
cd support-knowledge-bot
```

You should now be in the project root. Confirm:

```bash
ls
# Should show: README.md, docker-compose.yml, Makefile, scripts/, docs/, ...
```

---

## Step 2: Start Ollama

Ollama must be running on your **host machine** (not inside Docker) before you start the container.

**macOS / Windows (Ollama desktop app):**

Open the Ollama app from your Applications folder or system tray. The menu bar icon confirms it is running.

**Linux / headless:**

```bash
ollama serve
```

Leave this terminal open or run it as a background service.

**Verify Ollama is reachable:**

```bash
curl http://localhost:11434/api/tags
```

You should see a JSON response (even if the model list is empty). If you see `Connection refused`, Ollama is not running — start it before continuing.

---

## Step 3: Pull the required models

Run the setup script to pull all required models for the `dev-ollama` profile:

```bash
./scripts/setup_ollama.sh
```

This will pull:
- `qwen3:4b` — primary chat/reasoning model
- `qwen3:1.7b` — fallback/fast model
- `nomic-embed-text` — embedding model for document indexing

The script will print the exact config values to enter into Kotaemon in Step 7. **Save or screenshot that output.**

After it completes, confirm the models are installed:

```bash
ollama list
```

You should see all three models listed.

> **Note:** `setup_ollama.sh` is for the `dev-ollama` profile only. For demos use `demo-hosted`; for paid pilots use `pilot-hosted`.

---

## Step 4: Run the preflight check

Before starting Docker, confirm all prerequisites are in order:

```bash
./scripts/preflight.sh
```

The preflight script checks:
- Docker is installed and running
- `docker compose` is available
- Ollama is installed and reachable
- `qwen3:4b`, `qwen3:1.7b`, and `nomic-embed-text` are installed
- Port 7860 is not already in use
- `sample-data/support/` exists and has files

If the script prints `PREFLIGHT PASS`, continue to Step 5.

If it prints `PREFLIGHT FAIL`, fix each listed issue before continuing. The script tells you exactly what to fix.

---

## Step 5: Start Kotaemon

```bash
docker compose up -d
```

This pulls the Kotaemon image on first run (may take a few minutes on a slow connection) and starts the container in the background.

**Monitor startup:**

```bash
docker compose logs -f kotaemon
```

Wait until you see a log line like:

```
Running on local URL: http://0.0.0.0:7860
```

Press `Ctrl+C` to stop following logs. The container keeps running.

**Using Make:**

```bash
make up       # start
make logs     # follow logs
make down     # stop
```

---

## Step 6: Open Kotaemon

Open your browser and go to:

```
http://localhost:7860
```

You should see the Kotaemon login/home screen. If the page does not load, check that the container is running:

```bash
docker compose ps
```

The `kotaemon` service should show `running`.

> **Security note:** The app is bound to `127.0.0.1:7860` — it is only accessible from your local machine. It is not exposed to your network.

---

## Step 7: Configure Kotaemon to use Ollama

This is a manual step inside the Kotaemon UI.

1. Open `http://localhost:7860` in your browser.
2. Log in (default credentials are set on first launch — follow the on-screen prompt).
3. Navigate to **Settings → Resources** (or the model config section).
4. Add a new LLM resource using the **ChatOpenAI** vendor with these values:

```yaml
# dev-ollama profile — for local development only
vendor: ChatOpenAI
api_key: ollama        # any non-empty string; Ollama does not check keys
base_url: http://host.docker.internal:11434/v1/
model: qwen3:4b
```

5. Add a new embedding resource using **ChatOpenAI** (or the embedding variant) with:

```yaml
vendor: ChatOpenAI
api_key: ollama
base_url: http://host.docker.internal:11434/v1/
model: nomic-embed-text
```

6. Save both resources and set them as active.

**Important:** Use `http://host.docker.internal:11434/v1/` — **not** `http://localhost:11434/v1/`. From inside the Docker container, `localhost` refers to the container itself, not your host machine. `host.docker.internal` is the correct address to reach Ollama on the host.

For a detailed profile setup guide, see [docs/KOTAEMON_MODEL_SETUP.md](KOTAEMON_MODEL_SETUP.md).  
For inference profile YAML files, see [config/inference/dev-ollama.example.yml](../config/inference/dev-ollama.example.yml).

---

## Step 8: Upload sample docs

1. In Kotaemon, create a new **Collection** (e.g. `support-demo`).
2. Upload all six files from `sample-data/support/`:
   - `01_refund_policy.md`
   - `02_sso_escalation_sop.md`
   - `03_billing_macros.csv`
   - `04_release_notes.md`
   - `05_solved_tickets.csv`
   - `06_support_onboarding.md`
3. Wait for indexing to complete. Kotaemon will process and embed each file.

> **Tip:** Indexing is batch/async. Wait for the status indicators to clear before asking questions. Asking questions during active indexing may return incomplete results.

If you have a customer folder to prepare first, use the doc prep script:

```bash
python scripts/prepare_docs.py --input raw_docs/ --output prepared_docs/
```

Then upload from `prepared_docs/` instead.

---

## Step 9: Paste the support prompt pack

Kotaemon allows a custom system/instruction prompt for its QA pipeline.

1. Open the prompt settings in Kotaemon (Settings → Prompts or the conversation settings panel).
2. Open `prompt-packs/support_v1.md` from this repo.
3. Copy the full prompt (everything below the separator line).
4. Paste it into Kotaemon's system/QA prompt field.
5. Save.

This configures the bot to:
- Answer only from retrieved sources
- Produce the structured output format (Internal answer, Customer-ready reply, Sources used, Confidence, Escalate if, Suggested tag, Missing-doc note)
- Refuse to answer when sources do not support the question

For other verticals, see:
- `prompt-packs/ops_v1.md` — operations teams
- `prompt-packs/msp_it_v1.md` — MSP / IT helpdesk
- `prompt-packs/rfp_sales_v1.md` — RFP / pre-sales

---

## Step 10: Ask demo questions

Test the setup end-to-end with these questions against the sample collection:

| # | Question | Expected behavior |
|---|----------|-------------------|
| 1 | Can we refund a customer after 20 days? | Cites refund policy; answers yes with 30-day window |
| 2 | What should I do if a customer has an SSO group sync issue? | Cites SSO escalation SOP; lists triage steps |
| 3 | What changed in the latest SSO release? | Cites release notes; describes group sync change |
| 4 | Write a customer reply for a failed invoice payment. | Returns customer-ready reply from billing macros |
| 5 | Is there a Berlin office lunch policy? | Returns "Not enough source support" — correct refusal |

If questions 1–4 return cited answers and question 5 is refused, your local setup is working correctly.

For the full eval set (20 questions), see `evals/support_eval_questions.jsonl` and `evals/manual_eval_sheet.md`.

---

## Troubleshooting

### Ollama not reachable from the host

**Symptom:** `curl http://localhost:11434/api/tags` returns `Connection refused`.

**Likely cause:** Ollama is not running.

**Fix:**
- macOS/Windows: Open the Ollama app from Applications or system tray.
- Linux: Run `ollama serve` in a terminal and leave it open.

**Verify:** Retry `curl http://localhost:11434/api/tags` — it should return JSON.

---

### Kotaemon container cannot reach Ollama

**Symptom:** Models are set to `http://host.docker.internal:11434/v1/` but Kotaemon shows connection errors or times out.

**Likely cause:** Wrong base URL or Ollama is not running.

**Fix:**
1. Confirm Ollama is running on the host (see above).
2. Confirm the base URL inside Kotaemon is exactly `http://host.docker.internal:11434/v1/` — **not** `http://localhost:11434/v1/`.
3. On Linux, confirm `docker-compose.yml` includes the `extra_hosts` entry:
   ```yaml
   extra_hosts:
     - "host.docker.internal:host-gateway"
   ```
   This is already in the repo's `docker-compose.yml`.

**Verify:** Run a small chat completion from inside the container:

```bash
docker exec kotaemon curl -s http://host.docker.internal:11434/api/tags
```

If that returns JSON, the network path is working.

---

### Linux Docker cannot resolve `host.docker.internal` without `host-gateway`

**Symptom:** The container works on macOS/Windows but fails on Linux with DNS errors for `host.docker.internal`.

**Likely cause:** On Linux, Docker does not add `host.docker.internal` by default.

**Fix:** Confirm `docker-compose.yml` has:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

This is already present in the repo. If you are using a custom compose file, add it there.

---

### Port 7860 already in use

**Symptom:** `docker compose up` fails with `port is already allocated` or the browser shows `connection refused`.

**Likely cause:** Another app is using port 7860 (possibly a previous Kotaemon instance).

**Fix:**

```bash
# Find what is using port 7860
lsof -i :7860        # macOS/Linux
netstat -ano | findstr :7860   # Windows

# Stop the conflicting process, then:
docker compose up -d
```

Alternatively, change the host port in `docker-compose.yml`:

```yaml
ports:
  - "127.0.0.1:7861:7860"
```

Then open `http://localhost:7861`.

---

### Model too slow

**Symptom:** Responses take 30–120+ seconds per query on the `dev-ollama` profile.

**Likely cause:** Running a 4B parameter model on CPU without a GPU. This is expected on laptop hardware.

**This is not a bug.** The `dev-ollama` profile is for personal/local testing only. For demos use `demo-hosted`; for paid pilots use `pilot-hosted` (see [docs/INFERENCE_PROFILES.md](INFERENCE_PROFILES.md)).

**Mitigation for dev work:**
- Switch to the smaller fallback model `qwen3:1.7b` in Kotaemon Resources for faster iteration.
- Ask narrow, specific questions to reduce output length.
- Disable heavy LLM reranking in Kotaemon settings if available.

---

### Embedding model missing

**Symptom:** Kotaemon errors on indexing, or all similarity scores are zero/identical.

**Likely cause:** `nomic-embed-text` was not pulled, or the embedding resource is not set in Kotaemon.

**Fix:**

```bash
ollama pull nomic-embed-text
ollama list   # confirm it appears
```

Then confirm the Kotaemon embedding resource points to `nomic-embed-text` at `http://host.docker.internal:11434/v1/`.

> **Important:** If you change the embedding model after indexing documents, you must re-index all documents. The old embeddings are incompatible with the new model.

---

## Quick reference

```bash
# Full local start sequence
./scripts/setup_ollama.sh    # pull models (once)
./scripts/preflight.sh       # verify all prerequisites
docker compose up -d          # start Kotaemon

# Shortcuts via Make
make ollama     # run setup_ollama.sh
make preflight  # run preflight.sh
make up         # docker compose up -d
make logs       # follow container logs
make down       # stop container
make smoke      # run Ollama smoke test

# Reset demo data (requires confirmation)
./scripts/reset_local_data.sh
```

**App URL:** `http://localhost:7860`  
**Ollama URL (from host):** `http://localhost:11434`  
**Ollama URL (from inside Docker):** `http://host.docker.internal:11434/v1/`

---

## Next steps

- [docs/KOTAEMON_MODEL_SETUP.md](KOTAEMON_MODEL_SETUP.md) — detailed model config for all inference profiles
- [docs/DEMO_SCRIPT.md](DEMO_SCRIPT.md) — run a structured 10-minute demo
- [docs/CUSTOMER_ONBOARDING.md](CUSTOMER_ONBOARDING.md) — onboard a pilot customer
- [docs/INFERENCE_PROFILES.md](INFERENCE_PROFILES.md) — switch to `demo-hosted` for prospect demos or `pilot-hosted` for paid pilots
- [docs/TROUBLESHOOTING.md](TROUBLESHOOTING.md) — extended troubleshooting guide
