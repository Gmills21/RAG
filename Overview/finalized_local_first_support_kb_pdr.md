# PDR: Local-First SMB Support Knowledge Bot MVP

Version: 0.2
Date: 2026-05-14
Working product name: Support Knowledge Bot
Primary build environment: Cursor
Primary runtime: Docker + Ollama local models
Primary OSS base: Kotaemon

---

## 0. Executive summary

Build the fastest possible sellable MVP for a small-company internal knowledge assistant by using existing open-source software instead of building a RAG system from scratch.

The MVP is a local-first, document-upload-based support knowledge bot. It lets a small support, customer success, operations, or service team upload trusted docs and ask questions. The bot returns:

1. An internal answer.
2. A customer-ready response.
3. Citations and source snippets.
4. A confidence label.
5. Escalation guidance.
6. Suggested tags or next actions.

The MVP should NOT try to become a full Glean clone, full enterprise search, or full integration platform. It should be a packaged deployment of an existing OSS RAG product with local Ollama models, prompt templates, sample data, setup scripts, demo scripts, and customer onboarding materials.

The goal is to sell and run a first pilot without building a full custom SaaS platform. The product should stay local-first for development, demos, and guided validation, while using a dedicated single-customer VPS as the default deployment for the first real customer pilot.

---

## 1. Core strategy

### 1.1 Product wedge

Target one narrow use case:

"Private AI answer bot for growing support teams that are not ready for a full enterprise-search rollout."

### 1.2 Customer promise

"Upload your approved support docs, SOPs, macros, policies, and solved tickets. Your team can ask questions and get cited internal answers plus customer-ready replies. No full workspace integration required."

### 1.3 What we are really building

We are mostly building:

- A wrapper repo.
- Docker-based setup.
- Local-first development and demo workflow.
- Single-customer VPS deployment path for the first real pilot.
- Ollama local model setup.
- Prompt packs.
- Sample data.
- Customer onboarding guides.
- Demo scripts.
- Acceptance test checklists.
- Optional preprocessing script for messy docs.

We are NOT building:

- A custom RAG backend.
- A custom vector database layer.
- A custom citation viewer.
- A custom chat UI.
- A connector marketplace.
- A self-serve SaaS app.
- Slack/Google Drive/Jira APIs in v0.

### 1.4 OSS base decision

Use Kotaemon as the base app because it already provides the core features we need:

- Document QA web UI.
- Multi-user file collections.
- Local LLM support through Ollama.
- Hybrid retrieval.
- Citations.
- In-browser PDF/document preview with cited source highlighting.
- Configurable retrieval and prompts in the UI.
- Docker images.

### 1.5 Model decision

Default local setup:

- Chat LLM: qwen3:4b through Ollama.
- Low-resource fallback: qwen3:1.7b through Ollama.
- Embeddings: nomic-embed-text through Ollama.

The MVP must run without OpenAI, Anthropic, or other paid APIs by default.

A later paid-pilot configuration may optionally allow a stronger hosted model, but it must not be required for local testing.

---

## 2. MVP scope

### 2.1 In scope

The MVP must support:

1. Local-only operation.
2. Docker launch of Kotaemon.
3. Host-machine Ollama connection.
4. Pulling required local models.
5. Manual upload of files through the existing Kotaemon UI.
6. Support for at least PDF, DOCX, TXT, MD, CSV, and ZIP/folder-style workflows where possible.
7. Prompt packs for support, operations, and MSP/IT service use cases.
8. Sample support knowledge base for demos.
9. Setup instructions a non-expert founder can follow.
10. A one-command-ish local bootstrap flow.
11. Acceptance checks after each build step.
12. A customer pilot onboarding checklist.
13. A source-quality checklist so customers upload trusted docs, not random junk.
14. A manual eval question set.
15. A simple doc-prep script using open-source conversion tools where useful.
16. Local-first testing before any customer, VPN, or VPS setup.
17. A single-customer VPS deployment path for the first paid pilot.

### 2.2 Out of scope for v0

Do not build these in v0:

1. Slack history ingestion.
2. Google Drive API integration.
3. Jira API integration.
4. Zendesk/Intercom API integration.
5. SSO/SAML.
6. Role-based enterprise permissions beyond what the base app supports.
7. Billing.
8. Multi-tenant cloud SaaS.
9. Custom RAG app UI.
10. Custom vector search implementation.
11. Fine-tuning.
12. Agents that take actions in customer systems.
13. Browser extension.
14. Mobile app.
15. Admin analytics dashboard beyond what the base app and our docs/checklists provide.

### 2.3 Future scope after first pilot

Future versions may add:

1. Slack bot as chat interface, not as data source.
2. Google Drive selected-file import.
3. Jira CSV import template.
4. Zendesk CSV import template.
5. Better usage analytics.
6. Saved answer library.
7. Customer-specific branding.
8. Multi-customer managed hosting or self-serve hosted deployment.
9. A thin front-end landing portal that links to the deployed app.

---

## 3. Target user and buyer

### 3.1 First buyer

Target buyer:

- Head of Support.
- Head of CX.
- VP Customer Success.
- Support Ops Manager.
- COO.
- Founder at companies under 50 people.

### 3.2 First user

Target daily user:

- Support rep.
- Customer success manager.
- Implementation specialist.
- Onboarding specialist.
- Support team lead.

### 3.3 Ideal first customer profile

Best first customer:

- 30 to 300 employees.
- B2B SaaS, MSP, agency, implementation firm, or ops-heavy service business.
- Has 5 or more support/CS/ops people.
- Has docs spread across PDFs, Google Docs exports, Notion exports, Confluence exports, ticket exports, macros, and SOPs.
- Does not want a full enterprise-search rollout.
- Can share a curated folder of trusted docs for a pilot.

---

## 4. MVP user stories

### 4.1 Support rep asks an internal question

As a support rep, I want to ask "Can we refund this customer?" and receive an answer based only on uploaded policy docs, with a customer-ready reply and citations.

Acceptance:

- Answer references the refund policy source.
- Answer includes customer-ready wording.
- Answer includes confidence.
- Answer includes escalation conditions.
- Answer does not invent unsupported policy details.

### 4.2 New hire searches SOPs

As a new support hire, I want to ask "How do I escalate an SSO issue?" and receive the escalation process with source references.

Acceptance:

- Bot lists steps from the escalation SOP.
- Bot includes the correct owner or escalation team if present in the docs.
- Bot cites the SOP document.
- Bot says it does not know if the docs are missing the answer.

### 4.3 Manager validates source quality

As a support manager, I want to upload only approved docs so the bot does not answer from outdated or random files.

Acceptance:

- Documentation tells the manager what docs to upload first.
- Documentation tells the manager what docs NOT to upload.
- Documentation includes a folder template.
- Demo data follows the same format.

### 4.4 Founder demos the system to a prospect

As the founder/seller, I want to run a local demo using sample data and show citations, source preview, and support-specific outputs in under 10 minutes.

Acceptance:

- `./scripts/setup_ollama.sh` pulls local models.
- `docker compose up -d` starts the app.
- README explains first-run model setup.
- Sample docs are available.
- Demo script provides exact questions to ask.

---

## 5. Product flow

### 5.1 Admin setup flow

1. Clone this wrapper repo.
2. Install Docker.
3. Install Ollama.
4. Run `./scripts/setup_ollama.sh`.
5. Run `./scripts/preflight.sh`.
6. Run `docker compose up -d`.
7. Open `http://localhost:7860`.
8. Log in with default Kotaemon credentials if unchanged by the base app.
9. Configure local LLM and embedding model in Kotaemon resources/settings.
10. Create a collection named `Support KB Demo`.
11. Upload sample docs.
12. Apply or paste the support prompt template in settings.
13. Ask demo questions.

### 5.2 Customer pilot flow

1. Customer fills out source-quality checklist.
2. Customer provides a ZIP of approved docs or exported tickets.
3. We run `scripts/prepare_docs.py` on the folder if needed.
4. We upload prepared docs to a founder-operated local instance for guided validation.
5. We configure prompt template for their workflow.
6. We test 20 known questions with the customer.
7. We collect wrong answers and missing docs.
8. We refine docs and prompt template.
9. If quality is acceptable and the customer wants team access, we deploy a dedicated single-customer VPS pilot instance.
10. We upload only approved prepared docs into that pilot instance.
11. We run a 30-day pilot.
12. We use a customer-owned server/VPN deployment only if the customer explicitly requires it.

### 5.3 Deployment decision flow

Use the same app and repo across all modes. Only deployment configuration should change.

Default path:

1. Founder-operated local instance for demos and guided validation.
2. Dedicated single-customer VPS for the first real 5 to 25 user pilot.
3. Customer-owned machine/server plus VPN or private network only when required by customer security policy.

Local testing must not require a VPS, VPN, reverse proxy, customer domain, or customer infrastructure. The local path remains:

```bash
./scripts/setup_ollama.sh
./scripts/preflight.sh
docker compose up -d
open http://localhost:7860
```

---

## 6. Data source strategy

### 6.1 v0 data sources

Use manual upload only:

- PDF.
- DOCX.
- MD.
- TXT.
- CSV.
- HTML exports.
- ZIP/folder-based export if supported by the base app or preprocessed into individual files.

### 6.2 Highest-value support docs

Ask customers for:

1. Internal support SOPs.
2. Help center articles.
3. Support macros/templates.
4. Product docs.
5. Refund/billing/security policies.
6. Support onboarding docs.
7. Troubleshooting guides.
8. Top solved tickets exported as CSV.
9. Release notes/changelogs.
10. Escalation rules.

### 6.3 What not to upload first

Do not start with:

1. Full Slack exports.
2. Private DMs.
3. Entire Google Drive dumps.
4. Old meeting notes.
5. Unreviewed random docs.
6. Highly sensitive HR/legal docs.
7. Draft docs that conflict with official policies.
8. Duplicate old versions of the same policy.

### 6.4 Jira/Zendesk approach for v0

Do not use Jira/Zendesk APIs in v0.

Use exported CSVs instead:

- Last 100 to 1000 solved support tickets.
- Only tickets tagged with useful categories.
- Remove sensitive customer data where possible.
- Convert fields into a clean CSV with columns such as:
  - ticket_id
  - title
  - problem
  - resolution
  - tags
  - product_area
  - created_at
  - solved_at
  - source_url_optional

---

## 7. Technical architecture

### 7.1 Runtime architecture

Use the same app and repo for local testing and pilot deployment. Only configuration should change.

#### 7.1.1 Local development/demo runtime

Founder laptop or local machine:

- Ollama runs locally on port 11434.
- Models are pulled locally.
- Docker runs Kotaemon.
- Kotaemon connects to Ollama through OpenAI-compatible API settings.
- Kotaemon is accessed at `http://localhost:7860`.
- No VPS, VPN, reverse proxy, customer domain, or customer infrastructure is required.

Kotaemon container:

- Serves UI on port 7860.
- Binds to `127.0.0.1:7860` on the host by default.
- Stores app data in `./ktem_app_data` volume.
- Uses uploaded docs and its built-in retrieval/citation features.

#### 7.1.2 First-customer pilot runtime

Dedicated single-customer VPS:

- One VPS per customer for first pilots.
- Encrypted disk where available from the infrastructure provider.
- Docker runs Kotaemon.
- Ollama runs on the same VPS unless a stronger model fallback is explicitly approved.
- Kotaemon app data is stored in a customer-specific folder.
- A reverse proxy handles HTTPS and strong access control in front of the app.
- Kotaemon is not exposed directly to the public internet. Raw port 7860 stays bound to localhost or the private Docker network.
- Customer users access the app through a customer-specific HTTPS URL.

Deployment decision order:

1. Option C for demos and guided validation: founder-operated local instance.
2. Option B for the actual first pilot: dedicated single-customer VPS.
3. Option A only when required: customer-owned machine/server plus VPN or private network.

### 7.2 Model settings

In Kotaemon model/resource settings, configure:

LLM:

- Provider/type: OpenAI-compatible.
- API key: `ollama` or dummy value accepted by the app.
- Base URL from Docker container to host Ollama: `http://host.docker.internal:11434/v1/`.
- Model: `qwen3:4b`.

Embedding:

- Provider/type: OpenAI-compatible.
- API key: `ollama` or dummy value accepted by the app.
- Base URL from Docker container to host Ollama: `http://host.docker.internal:11434/v1/`.
- Model: `nomic-embed-text`.

Low-resource fallback LLM:

- Model: `qwen3:1.7b`.

### 7.3 Storage

Use the default Kotaemon app data folder mounted as:

`./ktem_app_data:/app/ktem_app_data`

For local testing, this can stay in the repo root.

For customer pilots, use a customer-specific folder, for example:

`/opt/support-knowledge-bot/customers/acme/ktem_app_data:/app/ktem_app_data`

Do not add custom cloud storage in v0. Do not mix multiple customer datasets in the same app data folder.

### 7.4 Security assumptions for v0

This MVP is for local demos and controlled pilots.

Rules:

1. Do not upload real sensitive customer data during internal testing.
2. Use fake docs for demos.
3. For customer pilots, get explicit written permission for uploaded docs.
4. Scope pilots to approved docs only.
5. Do not ingest full workspaces.
6. Avoid private messages, HR docs, secrets, tokens, credentials, or personal data.
7. Store all pilot docs in customer-specific folders.
8. Do not mix customer data in the same local app instance unless the base app clearly supports isolation and it has been tested.
9. Use a founder-operated local instance for demos and guided validation.
10. Use a dedicated single-customer VPS as the default first real pilot deployment.
11. Do not expose raw port 7860 directly to the public internet.
12. For VPS pilots, put the app behind HTTPS and strong access control.
13. Use customer-owned server/VPN deployment only if the customer requires it.

---

## 8. Repository structure to build

Cursor should create this wrapper repo structure:

```text
support-knowledge-bot/
  README.md
  docker-compose.yml
  docker-compose.pilot.yml
  Caddyfile.example
  .env.example
  .env.pilot.example
  .gitignore
  LICENSE_NOTES.md
  Makefile

  scripts/
    preflight.sh
    setup_ollama.sh
    smoke_test_ollama.sh
    prepare_docs.py
    reset_local_data.sh

  prompt-packs/
    support_v1.md
    ops_v1.md
    msp_it_v1.md
    rfp_sales_v1.md

  sample-data/
    support/
      01_refund_policy.md
      02_sso_escalation_sop.md
      03_billing_macros.csv
      04_release_notes.md
      05_solved_tickets.csv
      06_support_onboarding.md

  docs/
    LOCAL_SETUP.md
    KOTAEMON_MODEL_SETUP.md
    CUSTOMER_ONBOARDING.md
    SOURCE_QUALITY_CHECKLIST.md
    DEMO_SCRIPT.md
    ACCEPTANCE_TESTS.md
    TROUBLESHOOTING.md
    PILOT_PLAYBOOK.md
    PILOT_DEPLOYMENT.md
    DATA_HANDLING.md

  evals/
    support_eval_questions.jsonl
    manual_eval_sheet.md
```

---

## 9. Cursor build plan

Follow these steps one by one in Cursor. Do not move to the next step until the acceptance checks pass.

Each step contains:

- Goal.
- Cursor prompt.
- Expected output.
- Acceptance checks.

---

## Step 1: Create the wrapper repo skeleton

### Goal

Create the repo structure without building any RAG system ourselves.

### Cursor prompt

```text
Create a new repo for a local-first SMB support knowledge bot MVP. This is a wrapper around Kotaemon and Ollama, not a custom RAG app.

Create this exact folder structure:

support-knowledge-bot/
  README.md
  docker-compose.yml
  docker-compose.pilot.yml
  Caddyfile.example
  .env.example
  .env.pilot.example
  .gitignore
  LICENSE_NOTES.md
  Makefile
  scripts/
  prompt-packs/
  sample-data/support/
  docs/
  evals/

Add placeholder files for all docs and scripts listed in the PDR. Do not implement custom RAG code. The README should state that the MVP uses Kotaemon for document QA/citations and Ollama for local LLM/embeddings.
```

### Expected output

- All folders exist.
- All placeholder files exist.
- README clearly states this is a wrapper/packaging repo.

### Acceptance checks

Run:

```bash
find . -maxdepth 3 -type f | sort
```

Pass conditions:

- Output includes `docker-compose.yml`.
- Output includes `docker-compose.pilot.yml`.
- Output includes `Caddyfile.example`.
- Output includes `.env.pilot.example`.
- Output includes `scripts/setup_ollama.sh`.
- Output includes `prompt-packs/support_v1.md`.
- Output includes `sample-data/support/01_refund_policy.md`.
- Output includes `docs/LOCAL_SETUP.md`.
- Output includes `docs/PILOT_DEPLOYMENT.md`.
- README does not claim we built the RAG engine.

---

## Step 2: Add Docker Compose for Kotaemon

### Goal

Run Kotaemon locally with one Docker Compose command, persist data locally, and add the minimal pilot override needed for a single-customer VPS later.

### Cursor prompt

```text
Implement docker-compose.yml, docker-compose.pilot.yml, Caddyfile.example, and .env.pilot.example for the MVP.

Local docker-compose.yml requirements:
- Use the official Kotaemon Docker image: ghcr.io/cinnamon/kotaemon:main-full.
- Expose Gradio/Kotaemon on localhost only with 127.0.0.1:7860:7860.
- Set GRADIO_SERVER_NAME=0.0.0.0.
- Set GRADIO_SERVER_PORT=7860.
- Mount ./ktem_app_data to /app/ktem_app_data.
- Mount ./sample-data to /app/sample-data:ro so demo docs are visible in the container.
- Add extra_hosts so Linux Docker can resolve host.docker.internal using host-gateway.
- Add comments explaining that Ollama runs on the host machine and Kotaemon should connect to http://host.docker.internal:11434/v1/ from inside Docker.
- Do not add a custom RAG service.
- Do not add Postgres, pgvector, Qdrant, or a custom backend in v0.

Pilot docker-compose.pilot.yml requirements:
- Add a lightweight reverse proxy service such as Caddy.
- Publish only the reverse proxy on ports 80 and 443.
- Route the reverse proxy to the Kotaemon service on the private Docker network.
- Do not expose raw Kotaemon port 7860 publicly.
- Use environment variables for PUBLIC_HOST and basic auth values.
- Keep this as a single-customer deployment, not a multi-tenant SaaS setup.

Caddyfile.example requirements:
- Reverse proxy PUBLIC_HOST to kotaemon:7860.
- Include commented instructions for basic auth.
- Make clear that this is for a dedicated single-customer VPS pilot only.
```

### Expected output

`docker-compose.yml` contains a single `kotaemon` service using `ghcr.io/cinnamon/kotaemon:main-full` for local testing.

`docker-compose.pilot.yml` and `Caddyfile.example` add a minimal single-customer VPS path without changing the local dev flow.

### Acceptance checks

Run:

```bash
docker compose config
docker compose -f docker-compose.yml -f docker-compose.pilot.yml config
```

Pass conditions:

- Local Compose config is valid.
- Local config has exactly one service named `kotaemon`.
- Local port mapping includes `127.0.0.1:7860:7860`.
- Local config includes `host.docker.internal:host-gateway`.
- Volume mapping includes `./ktem_app_data:/app/ktem_app_data`.
- Pilot config includes a reverse proxy service.
- Pilot config does not expose raw Kotaemon port 7860 publicly.

---

## Step 3: Add Ollama setup script

### Goal

Make local model setup easy and cheap.

### Cursor prompt

```text
Implement scripts/setup_ollama.sh.

Requirements:
- POSIX bash script with set -euo pipefail.
- Check that the `ollama` command exists. If missing, print a clear installation message and exit 1.
- Check that the Ollama server responds at http://localhost:11434/api/tags. If not, print instructions to run `ollama serve` or start the Ollama desktop app.
- Pull these models:
  - qwen3:4b
  - qwen3:1.7b
  - nomic-embed-text
- After pulling, list installed models.
- Print the model config values to use in Kotaemon:
  - base_url: http://host.docker.internal:11434/v1/
  - llm model: qwen3:4b
  - fallback llm model: qwen3:1.7b
  - embedding model: nomic-embed-text
- Make the script executable.
```

### Expected output

`setup_ollama.sh` is executable and self-explanatory.

### Acceptance checks

Run:

```bash
bash -n scripts/setup_ollama.sh
ls -l scripts/setup_ollama.sh
```

Pass conditions:

- Bash syntax check passes.
- File is executable or README says to run `chmod +x scripts/setup_ollama.sh`.

Manual runtime check:

```bash
./scripts/setup_ollama.sh
```

Pass conditions:

- Script exits 0 if Ollama is installed and running.
- `ollama list` shows the three models.

---

## Step 4: Add Ollama smoke test script

### Goal

Verify local chat and embeddings work before launching Kotaemon.

### Cursor prompt

```text
Implement scripts/smoke_test_ollama.sh.

Requirements:
- POSIX bash script with set -euo pipefail.
- Check Ollama tags endpoint.
- Send a tiny chat request to the OpenAI-compatible chat completions endpoint at http://localhost:11434/v1/chat/completions using model qwen3:4b.
- Send a tiny embeddings request to http://localhost:11434/v1/embeddings using model nomic-embed-text.
- Do not require jq. Use grep or Python stdlib if needed.
- Print PASS/FAIL messages for:
  - Ollama server reachable.
  - Chat completion returned content.
  - Embeddings returned vector data.
```

### Expected output

A script that confirms Ollama is usable for both chat and embeddings.

### Acceptance checks

Run:

```bash
bash -n scripts/smoke_test_ollama.sh
./scripts/smoke_test_ollama.sh
```

Pass conditions:

- Script prints PASS for server, chat, and embeddings.
- Script exits 0.

---

## Step 5: Add preflight script

### Goal

Make setup failures obvious before demos.

### Cursor prompt

```text
Implement scripts/preflight.sh.

Requirements:
- POSIX bash script with set -euo pipefail.
- Check for Docker.
- Check Docker daemon is running.
- Check for docker compose availability.
- Check for Ollama command.
- Check Ollama server is reachable.
- Check that qwen3:4b, qwen3:1.7b, and nomic-embed-text are installed.
- Check port 7860 is not already in use, or warn clearly if it is.
- Check that sample-data/support exists and has files.
- Print a final clear result:
  - "PREFLIGHT PASS: ready to run docker compose up -d"
  - or "PREFLIGHT FAIL" with actionable fixes.
```

### Expected output

A script that makes demo readiness clear.

### Acceptance checks

Run:

```bash
bash -n scripts/preflight.sh
./scripts/preflight.sh
```

Pass conditions:

- Script gives actionable messages.
- It does not silently pass missing dependencies.
- It prints the exact next command when ready.

---

## Step 6: Add Makefile shortcuts

### Goal

Make the project easy to run without memorizing commands.

### Cursor prompt

```text
Implement a simple Makefile.

Targets:
- help: list available commands.
- ollama: run scripts/setup_ollama.sh.
- smoke: run scripts/smoke_test_ollama.sh.
- preflight: run scripts/preflight.sh.
- up: run docker compose up -d.
- down: run docker compose down.
- logs: run docker compose logs -f kotaemon.
- reset-data: run scripts/reset_local_data.sh.

Do not add complex build steps. This repo is a wrapper, not an app build.
```

### Expected output

`make help` works and lists commands.

### Acceptance checks

Run:

```bash
make help
make preflight
```

Pass conditions:

- `make help` prints target names.
- `make preflight` calls the script.

---

## Step 7: Add sample support data

### Goal

Create a fake but realistic demo corpus for sales demos and acceptance testing.

### Cursor prompt

```text
Fill sample-data/support with realistic fake support docs. Do not include real company data.

Create these files:

1. 01_refund_policy.md
- Include a 30-day refund policy.
- Include exceptions: annual enterprise contracts, chargebacks, suspected fraud.
- Include finance approval requirement for invoices over $5,000.

2. 02_sso_escalation_sop.md
- Include SSO provisioning issue triage steps.
- Include severity levels.
- Include when to escalate to Engineering Support.
- Include customer-safe wording.

3. 03_billing_macros.csv
- Columns: macro_name, use_case, customer_reply, internal_note, tags.
- Include 5 macros.

4. 04_release_notes.md
- Include 3 fake product releases.
- Include one release that changed SSO group sync behavior.

5. 05_solved_tickets.csv
- Columns: ticket_id, title, problem, resolution, tags, product_area, solved_at.
- Include 15 fake solved tickets.
- Include refunds, SSO, billing, integrations, onboarding.

6. 06_support_onboarding.md
- Include how new reps should use the knowledge bot.
- Include rules for trusting answers only when citations exist.
```

### Expected output

Sample data contains enough detail to produce useful answers with citations.

### Acceptance checks

Run:

```bash
wc -l sample-data/support/*
head -n 5 sample-data/support/05_solved_tickets.csv
```

Pass conditions:

- All six files exist.
- CSVs have headers.
- Refund and SSO facts appear in sample docs.
- No real company names or private data.

---

## Step 8: Add support prompt pack

### Goal

Make generic RAG output feel like a support-specific product.

### Cursor prompt

```text
Implement prompt-packs/support_v1.md.

This prompt will be pasted into Kotaemon's configurable QA/retrieval prompt settings where possible.

The prompt must instruct the assistant to:
- Act as an internal support answer assistant.
- Use only retrieved sources.
- Never invent policy details.
- Say "Not enough source support" when the uploaded docs do not answer the question.
- Cite every source used.
- Produce this exact output format:

Internal answer:

Customer-ready reply:

Sources used:

Confidence:
- High / Medium / Low

Escalate if:

Suggested tag or macro:

Missing-doc note:

Add 5 example questions at the bottom for demo use.
```

### Expected output

Prompt pack is copy-paste ready.

### Acceptance checks

Manual read check:

- Prompt includes strict source-grounding rules.
- Prompt includes customer-ready reply section.
- Prompt includes "Not enough source support" behavior.
- Prompt includes exact output headings.

---

## Step 9: Add ops, MSP/IT, and RFP prompt packs

### Goal

Prepare adjacent vertical templates without building new product logic.

### Cursor prompt

```text
Implement these prompt packs:

1. prompt-packs/ops_v1.md
Output format:
- Direct answer
- Checklist
- Owner or responsible team
- Deadline or timing
- Source used
- Confidence
- Escalate if
- Missing-doc note

2. prompt-packs/msp_it_v1.md
Output format:
- Likely fix
- Troubleshooting steps
- Client-safe explanation
- Source used
- Confidence
- Escalate to
- Related ticket/runbook
- Missing-doc note

3. prompt-packs/rfp_sales_v1.md
Output format:
- Approved answer draft
- Source used
- Risk/compliance note
- Needs legal/security review?
- Confidence
- Reusable snippet
- Missing-doc note

All prompts must require source-grounded answers and refusal when docs do not support an answer.
```

### Expected output

Three vertical prompt packs exist and are ready to paste into the base app.

### Acceptance checks

Run:

```bash
grep -R "Not enough source support\|Missing-doc" prompt-packs
```

Pass conditions:

- Each prompt has missing-doc/refusal behavior.
- Each prompt has a different vertical-specific output format.

---

## Step 10: Add local setup docs

### Goal

Make setup clear enough that a founder can follow it during testing.

### Cursor prompt

```text
Write docs/LOCAL_SETUP.md.

It must include:
- Prerequisites: Docker, Docker Compose, Ollama.
- Step 1: clone repo.
- Step 2: start Ollama.
- Step 3: run ./scripts/setup_ollama.sh.
- Step 4: run ./scripts/preflight.sh.
- Step 5: run docker compose up -d.
- Step 6: open http://localhost:7860.
- Note that local testing does not require a VPS, VPN, reverse proxy, Caddy, customer domain, or customer infrastructure.
- Step 7: configure Kotaemon resources to use Ollama.
- Step 8: upload sample docs.
- Step 9: paste support prompt pack.
- Step 10: ask demo questions.

Also include troubleshooting for:
- Ollama not reachable from host.
- Kotaemon container cannot reach Ollama.
- Linux Docker cannot resolve host.docker.internal without host-gateway.
- Port 7860 already in use.
- Model too slow.
- Embedding model missing.
```

### Expected output

A beginner-friendly local setup guide.

### Acceptance checks

Manual read check:

- A user can follow setup in order.
- It includes exact commands.
- It includes the Docker-to-host Ollama base URL.

---

## Step 11: Add Kotaemon model setup docs

### Goal

Make the manual UI configuration step explicit.

### Cursor prompt

```text
Write docs/KOTAEMON_MODEL_SETUP.md.

It must explain how to configure Kotaemon to use Ollama through an OpenAI-compatible endpoint.

Include these values:

For LLM:
- type/provider: OpenAI-compatible or OpenAI, depending on Kotaemon UI wording
- api_key: ollama
- base_url: http://host.docker.internal:11434/v1/
- model: qwen3:4b

For embeddings:
- type/provider: OpenAI-compatible or OpenAI, depending on Kotaemon UI wording
- api_key: ollama
- base_url: http://host.docker.internal:11434/v1/
- model: nomic-embed-text

Also mention:
- If running Kotaemon outside Docker, use http://localhost:11434/v1/ instead.
- If qwen3:4b is too slow, use qwen3:1.7b.
- Disable heavy reranking/relevance scoring if the laptop struggles.
- Start a new conversation after changing models.
```

### Expected output

A setup doc focused only on model configuration.

### Acceptance checks

Manual read check:

- It contains all four values: api key, base URL, LLM model, embedding model.
- It explains `host.docker.internal` vs `localhost`.
- It includes low-resource fallback.

---

## Step 12: Add customer onboarding docs

### Goal

Turn setup into a sellable service process.

### Cursor prompt

```text
Write docs/CUSTOMER_ONBOARDING.md.

It must include:
- What we ask the customer to send.
- What docs to include first.
- What docs to avoid.
- How to export solved tickets as CSV.
- How to label docs as trusted/current.
- How to define 20 known questions before the pilot.
- What success means after 30 days.

Include a customer-facing message we can send:

"We do not need access to your whole workspace. Send us only the approved docs your team already trusts."

Include a folder template:

customer_docs/
  01_policies/
  02_sops/
  03_macros/
  04_product_docs/
  05_solved_tickets/
  06_release_notes/
```

### Expected output

A practical guide for onboarding a pilot customer.

### Acceptance checks

Manual read check:

- It reduces customer fear about access.
- It explains no full workspace integration.
- It includes a clean folder template.

---

## Step 13: Add source quality checklist

### Goal

Avoid bad RAG results caused by bad source docs.

### Cursor prompt

```text
Write docs/SOURCE_QUALITY_CHECKLIST.md.

It must include:
- Approved docs checklist.
- Outdated docs checklist.
- Duplicate docs checklist.
- Sensitive docs warning.
- Minimum viable support corpus.
- Naming conventions.
- Recommended metadata fields.
- Pre-pilot cleanup checklist.

Include a rule:
"If two docs conflict, do not upload both until the customer chooses the current source of truth."

Include a minimum corpus recommendation:
- 10 to 30 SOPs/policies.
- 20 to 100 help-center or product docs.
- 50 to 500 solved tickets if available.
- 10 to 30 support macros/templates if available.
```

### Expected output

A checklist that improves answer quality before any engineering changes.

### Acceptance checks

Manual read check:

- It teaches customers how to curate docs.
- It explains why not to upload everything.
- It includes conflict handling.

---

## Step 14: Add demo script

### Goal

Create a reliable sales demo using sample docs.

### Cursor prompt

```text
Write docs/DEMO_SCRIPT.md.

It must include:
- 10-minute demo flow.
- Exact sample docs to upload.
- Exact prompt pack to paste.
- Exact questions to ask.
- What good answers should contain.
- How to show citations/source preview.
- How to handle a bad answer in the demo.

Demo questions:
1. Can we refund a customer after 20 days?
2. Can we refund an annual enterprise customer without approval?
3. What should I do if a customer has an SSO group sync issue?
4. What changed in the latest SSO release?
5. Write a customer-ready reply for a failed invoice payment.
6. What tag should I use for a refund request?
7. Is there a Berlin office lunch policy?

For question 7, the expected answer is that the docs do not contain enough support.
```

### Expected output

A demo script that proves citations, formatting, and refusal behavior.

### Acceptance checks

Manual read check:

- Script can be followed live.
- It includes unsupported-question test.
- It emphasizes source citations.

---

## Step 15: Add acceptance tests doc

### Goal

Create a full manual QA checklist for the MVP.

### Cursor prompt

```text
Write docs/ACCEPTANCE_TESTS.md.

Include these sections:

1. Environment checks.
2. Ollama checks.
3. Docker/Kotaemon checks.
4. Model configuration checks.
5. Document upload checks.
6. Retrieval/citation checks.
7. Support prompt output checks.
8. Refusal behavior checks.
9. Performance checks.
10. Pilot readiness checks.

For each check, include:
- Test name.
- Steps.
- Expected result.
- Pass/fail box.

Use the sample-data/support docs for retrieval tests.
```

### Expected output

A QA checklist that can be used before every demo.

### Acceptance checks

Manual read check:

- It has clear pass/fail criteria.
- It includes the unsupported-question test.
- It includes source preview/citation verification.

---

## Step 16: Add eval question set

### Goal

Provide repeatable questions to test RAG quality manually.

### Cursor prompt

```text
Create evals/support_eval_questions.jsonl and evals/manual_eval_sheet.md.

support_eval_questions.jsonl format, one JSON object per line:
{
  "id": "Q001",
  "question": "...",
  "expected_behavior": "...",
  "must_cite": ["expected file name"],
  "should_refuse": false
}

Create at least 20 questions:
- 12 answerable from sample docs.
- 5 unsupported questions that should produce "Not enough source support".
- 3 ambiguous/conflict-style questions.

manual_eval_sheet.md should include columns:
- ID
- Question
- Expected behavior
- Actual answer notes
- Correct source cited? yes/no
- Hallucinated? yes/no
- Customer-ready reply usable? yes/no
- Pass/fail
```

### Expected output

Repeatable test set exists.

### Acceptance checks

Run:

```bash
python - <<'PY'
import json
from pathlib import Path
p = Path('evals/support_eval_questions.jsonl')
lines = p.read_text().strip().splitlines()
assert len(lines) >= 20
for line in lines:
    obj = json.loads(line)
    assert 'id' in obj and 'question' in obj and 'expected_behavior' in obj
print('eval jsonl ok')
PY
```

Pass conditions:

- JSONL parses.
- At least 20 questions exist.

---

## Step 17: Add document preparation script

### Goal

Help prepare customer docs without building our own retrieval system.

### Cursor prompt

```text
Implement scripts/prepare_docs.py.

Purpose:
Prepare a folder of customer-provided docs for upload into Kotaemon. This is a preprocessing/helper script only. It does not build a RAG index.

Requirements:
- Python 3.10+.
- Accept input folder and output folder arguments:
  python scripts/prepare_docs.py --input raw_docs --output prepared_docs
- Create output folder if missing.
- Walk input folder recursively.
- Skip hidden files and common junk files like .DS_Store.
- Copy .md, .txt, and .csv files directly.
- For .docx, .pptx, .xlsx, .pdf, .html files, try to convert to Markdown using markitdown if installed.
- If markitdown is not installed, copy the file as-is and add a warning to the manifest.
- Create MANIFEST.csv with columns:
  original_path, output_path, file_type, action, warning
- Sanitize output filenames to avoid weird characters.
- Do not delete the input files.
- Do not upload anything automatically.
- Print a summary at the end.

Also update README with install instructions:
  pip install 'markitdown[all]'
```

### Expected output

A helper script that prepares docs and creates a manifest.

### Acceptance checks

Run:

```bash
python scripts/prepare_docs.py --input sample-data/support --output /tmp/prepared_support_docs
ls /tmp/prepared_support_docs
cat /tmp/prepared_support_docs/MANIFEST.csv
```

Pass conditions:

- Script exits 0.
- Output folder contains prepared files.
- Manifest exists.
- Sample MD/CSV files are copied.

---

## Step 18: Add reset-local-data script

### Goal

Make it easy to reset the demo environment.

### Cursor prompt

```text
Implement scripts/reset_local_data.sh.

Requirements:
- POSIX bash script with set -euo pipefail.
- Stop Docker Compose if running.
- Ask for explicit confirmation before deleting ./ktem_app_data.
- Support a --yes flag for non-interactive reset.
- Delete ./ktem_app_data only after confirmation.
- Recreate ./ktem_app_data directory.
- Print next command: docker compose up -d.
```

### Expected output

Safe reset script.

### Acceptance checks

Run:

```bash
bash -n scripts/reset_local_data.sh
./scripts/reset_local_data.sh --yes
ls -ld ktem_app_data
```

Pass conditions:

- Script syntax passes.
- It requires confirmation unless `--yes` is used.
- It does not delete anything outside `./ktem_app_data`.

---

## Step 19: Add troubleshooting guide

### Goal

Prevent common demo failures.

### Cursor prompt

```text
Write docs/TROUBLESHOOTING.md.

Include fixes for:
- Docker not running.
- Port 7860 already in use.
- Ollama not installed.
- Ollama installed but server not running.
- Kotaemon cannot reach Ollama from Docker.
- Wrong base URL: localhost vs host.docker.internal.
- qwen3:4b too slow.
- Embeddings failing.
- Source citations not appearing.
- Answers hallucinating.
- Uploaded docs not searchable.
- Need to reset all local data.

Each issue should include:
- Symptom.
- Likely cause.
- Fix.
- Verification command or manual check.
```

### Expected output

A practical troubleshooting doc.

### Acceptance checks

Manual read check:

- It addresses model, Docker, citation, and retrieval issues.
- It includes verification commands.

---

## Step 20: Add pilot playbook

### Goal

Connect the MVP to sales and first-customer delivery.

### Cursor prompt

```text
Write docs/PILOT_PLAYBOOK.md and docs/PILOT_DEPLOYMENT.md.

For docs/PILOT_PLAYBOOK.md, include:
- Who this MVP is for.
- Who it is not for.
- 30-day pilot structure.
- Recommended first-pilot price range: $1,500 to $5,000 setup/pilot.
- One-team scope: 5 to 25 users.
- Data source limit: approved docs plus optional CSV exports only.
- Success metrics:
  - 100 real questions asked.
  - 10 useful saved answers.
  - 5 missing/outdated docs identified.
  - customer confirms it reduces repeated questions.
- Weekly check-in template.
- End-of-pilot conversion script.
- What to do if answer quality is bad.
- What to do if customer asks for Slack/Drive/Jira APIs.
- Deployment path:
  - Use founder-operated local instance for demos and guided validation.
  - Use a dedicated single-customer VPS for the first real pilot.
  - Use customer-owned server/VPN only when required.
  - Do not build multi-tenant SaaS in v0.

For docs/PILOT_DEPLOYMENT.md, include:
- Local testing path: docker compose up -d and http://localhost:7860.
- Pilot path: dedicated single-customer VPS.
- Required VPS setup assumptions: Docker, Ollama, domain, HTTPS reverse proxy, strong access control, encrypted disk where available.
- How to run the pilot config with docker-compose.pilot.yml.
- Rule: do not expose raw Kotaemon port 7860 publicly.
- Rule: one customer per VPS for first pilots.
- Rule: use customer-specific ktem_app_data and customer_docs folders.
- How to move from local validation to VPS pilot by copying only approved prepared docs and prompt configuration.

Positioning line:
"We deploy a private AI answer bot from the docs your team already trusts. No full workspace integration required."
```

### Expected output

A playbook and deployment guide that turn the technical MVP into a sellable first-customer pilot.

### Acceptance checks

Manual read check:

- It gives a concrete pilot scope.
- It has success metrics.
- It deflects premature API integration requests.
- It clearly says the default first real pilot is a dedicated single-customer VPS.
- It clearly says local testing still works before any VPS/VPN/customer setup.

---

## Step 21: Add data handling guide

### Goal

Avoid accidental mishandling of customer files.

### Cursor prompt

```text
Write docs/DATA_HANDLING.md.

Include:
- Use fake data for demos.
- For customer pilots, use only approved docs.
- Do not request full workspace exports.
- Do not request Slack DMs/private channels.
- Avoid HR/legal/secrets/credentials.
- Keep each customer in a separate local instance, dedicated single-customer VPS, or clearly separated app data folder.
- Use customer-specific folder naming.
- Do not expose raw port 7860 publicly during customer pilots.
- Delete pilot data after pilot if customer requests.
- Do not mix multiple customer datasets in the same demo.
- Recommended pre-pilot written permission note.

This is not legal advice, but should be operationally cautious.
```

### Expected output

A safety guide for founder-led pilots.

### Acceptance checks

Manual read check:

- It clearly says not to ingest everything.
- It recommends approved docs only.
- It includes deletion/separation practices.

---

## Step 22: Update README as the main control panel

### Goal

Make README the file a founder opens first.

### Cursor prompt

```text
Rewrite README.md so it is the main control panel for this wrapper MVP.

Sections:
1. What this is.
2. What this is not.
3. Quick start.
4. Architecture and deployment modes.
5. Commands.
6. Model configuration values.
7. Demo flow.
8. Prompt packs.
9. Customer pilot flow.
10. Local testing vs single-customer VPS pilot deployment.
11. Troubleshooting links.
11. License and OSS notes.

Quick start commands:
- ./scripts/setup_ollama.sh
- ./scripts/preflight.sh
- docker compose up -d
- open http://localhost:7860

Make it clear that Kotaemon is the base RAG app and this repo packages it for a support-team MVP. Make it clear that local testing works before any VPS, VPN, reverse proxy, domain, or customer infrastructure setup.
```

### Expected output

README is useful and concise.

### Acceptance checks

Manual read check:

- A new user understands what to do first.
- It does not oversell the project as custom IP.
- It links to all docs.

---

## Step 23: Full MVP run acceptance

### Goal

Prove the whole thing works locally.

### Manual steps

Run:

```bash
./scripts/setup_ollama.sh
./scripts/preflight.sh
docker compose up -d
```

Open:

```text
http://localhost:7860
```

Configure Kotaemon:

```text
LLM base_url: http://host.docker.internal:11434/v1/
LLM model: qwen3:4b
Embedding base_url: http://host.docker.internal:11434/v1/
Embedding model: nomic-embed-text
```

Create a collection:

```text
Support KB Demo
```

Upload:

```text
sample-data/support/*
```

Paste:

```text
prompt-packs/support_v1.md
```

Ask:

1. Can we refund a customer after 20 days?
2. Can we refund an annual enterprise customer without approval?
3. What should I do if a customer has an SSO group sync issue?
4. What changed in the latest SSO release?
5. Write a customer-ready reply for a failed invoice payment.
6. Is there a Berlin office lunch policy?

### Pass conditions

The MVP passes if:

- App loads at localhost:7860.
- Ollama chat and embeddings work.
- Sample docs upload and index.
- Answer for refund question cites refund policy.
- Answer for SSO question cites SSO escalation SOP or release notes.
- Answer includes customer-ready reply section.
- Answer includes confidence section.
- Unsupported Berlin lunch policy question refuses or says not enough source support.
- Source preview/citations can be shown in the UI.
- No paid API key is required.

---

## 10. Prompt pack content requirements

### 10.1 Support prompt pack exact template

The support prompt pack should include this or a close variant:

```text
You are an internal support answer assistant for a growing B2B software company.

Your job is to answer support-team questions using only the retrieved source documents. You must not invent company policy, pricing, security, billing, legal, product, or escalation details.

Rules:
1. Use only the retrieved sources.
2. Cite every source used.
3. If the sources do not contain enough information, say: "Not enough source support."
4. Do not answer from general knowledge when company-specific policy is required.
5. Prefer the most recent and most specific source.
6. If sources conflict, say that the sources conflict and identify the conflict.
7. For customer-facing wording, be clear, calm, and concise.
8. Never reveal private internal notes in the customer-ready reply.

Return the answer in this exact format:

Internal answer:
[Answer for the support rep.]

Customer-ready reply:
[Message the rep can send to the customer. If there is not enough source support, do not draft a definitive customer reply.]

Sources used:
[List source names, page/section/snippet if available.]

Confidence:
High / Medium / Low

Escalate if:
[Conditions that require a manager, finance, engineering, security, or legal escalation.]

Suggested tag or macro:
[Relevant support tag or macro if supported by the sources.]

Missing-doc note:
[What document would be needed if the answer is incomplete.]
```

---

## 11. MVP quality bar

### 11.1 Good enough for internal testing

The MVP is good enough for internal testing when:

- It runs locally.
- It uses local LLM and embeddings.
- It can ingest sample docs.
- It produces cited answers.
- It can refuse unsupported questions.
- It has support-specific formatting.
- It can be demoed in under 10 minutes.

### 11.2 Good enough for first prospect demo

The MVP is good enough for a prospect demo when:

- The demo script runs twice in a row without setup changes.
- At least 5 answerable demo questions work.
- At least 1 unsupported question is refused.
- Source citations are visible.
- Model latency is acceptable for a demo.
- The seller can explain local-only/no full workspace integration.

### 11.3 Good enough for first paid pilot

The MVP is good enough for a paid pilot when:

- Customer signs off on approved docs only.
- Customer understands this is v0 and scoped.
- Customer provides 20 known questions.
- Bot answers at least 70% of known questions acceptably after initial doc cleanup.
- Customer agrees on pilot success metrics.
- Customer data is separated from demo data.
- The real pilot runs on a dedicated single-customer VPS unless the customer requires a customer-owned server/VPN deployment.
- Raw Kotaemon port 7860 is not exposed directly to the public internet.
- There is a clear fallback if local model quality is too weak.

---

## 12. Fallbacks and known risks

### 12.1 Local model quality may be weak

Risk:

- qwen3:4b may produce weaker answers than hosted frontier models.

Mitigation:

- Keep docs curated.
- Keep prompts strict.
- Keep questions narrow.
- Use citations to build trust.
- For a serious customer pilot, allow optional model upgrade.

### 12.2 Retrieval may find wrong chunks

Risk:

- Bad docs, duplicates, or vague questions lead to wrong retrieval.

Mitigation:

- Use source-quality checklist.
- Remove outdated/conflicting docs.
- Add eval questions.
- Refine collection contents before changing code.

### 12.3 Customer asks for integrations too early

Risk:

- Prospect asks for Slack, Drive, Jira, Zendesk APIs before proving value.

Mitigation:

- Say v0 uses approved docs and CSV exports to avoid admin-heavy integrations.
- Offer integrations only after pilot success.
- Use Slack later as an interface, not first as a source.

### 12.4 OSS licensing and branding

Risk:

- We accidentally violate OSS licenses or misrepresent third-party code.

Mitigation:

- Preserve license notices.
- Document OSS dependencies.
- Do not claim Kotaemon code as ours.
- Get legal review before commercial distribution or deep fork.

---

## 13. Commercial packaging

### 13.1 First offer

Offer:

"We deploy a private AI answer bot from the docs your support team already trusts. It gives cited internal answers, customer-ready replies, and escalation guidance. No full workspace integration required."

### 13.2 Pilot pricing

Suggested first-pilot range:

- $1,500 to $5,000 setup/pilot.
- 30 days.
- 5 to 25 users.
- One team.
- Approved docs and optional CSV exports only.

### 13.3 Pilot success metrics

Pick 2 to 4:

- 100 real questions asked.
- 10 useful saved answers.
- 5 missing/outdated docs identified.
- 30% fewer repeated questions in internal channels.
- New support hire can answer common questions without asking a senior rep.
- Manager confirms output quality is good enough for continued use.

---

## 14. Final instruction to Cursor

Do not build a new RAG product unless explicitly instructed later.

The MVP is successful if a founder can:

1. Run local models.
2. Launch Kotaemon.
3. Upload trusted support docs.
4. Paste a support prompt template.
5. Ask questions.
6. Get cited support-specific answers.
7. Demo it to a prospect.
8. Run a first paid pilot on a dedicated single-customer VPS unless the customer requires customer-owned infrastructure.

Prioritize setup reliability, prompt quality, docs, sample data, and pilot workflow over custom software.

---

## 15. Reference notes

These references were used when choosing the stack. Re-check before production use:

- Kotaemon GitHub/docs: document QA UI, Docker images, Ollama support, hybrid retrieval, citations, PDF preview/highlights.
- Kotaemon local model setup docs: Ollama via OpenAI-compatible endpoint, `host.docker.internal` when running through Docker.
- Ollama docs: OpenAI-compatible local API and embeddings.
- Microsoft MarkItDown: document-to-Markdown conversion helper for LLM/RAG pipelines.

