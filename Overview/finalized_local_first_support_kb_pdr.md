# PDR: Support Knowledge Bot — MVP with Enterprise-Ready Architecture

Version: 0.3
Date: 2026-05-15
Working product name: Support Knowledge Bot
Primary build environment: Cursor
Primary runtime: Docker + Kotaemon (inference via configurable profiles)
Primary OSS base: Kotaemon (engine layer; UI may be replaced in a later phase)
North-star product shape: Glean-like workplace search — **find the right doc, cite the passage, answer in under 30 seconds** after indexing

---

## 0. Executive summary

Build the fastest possible sellable MVP for a small-company internal knowledge assistant by using existing open-source software instead of building a RAG system from scratch — **while architecting every layer so a Glean-like enterprise product can be implemented without a rewrite.**

The MVP is a **search-first**, document-based support knowledge bot. After a batch indexing window (not user-facing latency), an agent asks *"where is X documented?"* and gets **accurate citations** from their knowledge base in **under 30 seconds** during live use.

The bot returns:

1. Retrieved source documents and snippets (primary UX).
2. An internal answer grounded in those sources.
3. A customer-ready response (when sources support it).
4. Citations and source snippets with location in document.
5. A confidence label.
6. Escalation guidance.
7. Suggested tags or next actions.

**Phased product strategy:**

| Phase | Goal | Inference | Data | Tenancy |
|-------|------|-----------|------|---------|
| **0 — MVP build** | Wrapper, demo, first pilot | Ollama on laptop = **dev only**; demo/pilot use **hosted or GPU profile** for SLA | Manual upload + connector **stubs** | One instance per demo/pilot |
| **1 — Paid pilot** | 5–25 users, sub-30s cited queries | **OpenAI/Azure default**; Ollama optional on GPU VPS | Upload + CSV exports; connector interfaces documented | **One VPS per customer** |
| **2 — Enterprise** | Glean-shaped: connectors, SSO, permissions | Customer choice: hosted API or private cloud GPU | Drive, Confluence, Slack export paths, etc. | VPS per customer → optional multi-tenant SaaS |

v0 does **not** ship full Glean (connector marketplace, multi-tenant SaaS, SSO). v0 **does** ship **architecture, config profiles, docs, stubs, and demo behavior** so Phase 2 is configuration and incremental build — not a greenfield rewrite.

The goal is to sell and run a first pilot without building a full custom SaaS platform, while making the **demo itself** demonstrate the enterprise direction (search-first, SLA, swappable inference, extension points).

---

## 1. Core strategy

### 1.1 Product wedge

Target one narrow use case:

"Private AI answer bot for growing support teams that are not ready for a full enterprise-search rollout."

### 1.2 Customer promise

"Upload your approved support docs, SOPs, macros, policies, and solved tickets. Your team can ask questions and get cited internal answers plus customer-ready replies. No full workspace integration required."

### 1.3 What we are really building

We are mostly building:

- A wrapper repo with **explicit architecture boundaries** (data plane, control plane, inference, tenancy, platform).
- Docker-based setup with **inference profiles** (dev-ollama vs pilot-hosted).
- **Search-first** demo and pilot UX guidance (retrieval + citations before long chat).
- Single-customer VPS deployment path for the first real pilot.
- Ollama setup for **local development only**.
- Query SLA validation script and acceptance criteria.
- Extension stubs and docs for connectors, SSO, audit, and tenancy.
- Prompt packs, sample data, onboarding, demo scripts, evals.
- Optional preprocessing script for messy docs.

We are NOT building in v0 (but we **document and stub** for Phase 2):

- A custom RAG backend (Kotaemon remains the engine in v0).
- A custom vector database layer.
- Live connector sync (Drive, Confluence APIs).
- Full SSO/SAML or document-level ACL product.
- Multi-tenant SaaS.
- Slack/Google Drive/Jira **live APIs** in v0.

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

### 1.5 Inference decision (profiles, not one stack)

Inference is selected by **profile**, not hard-coded to Ollama:

| Profile | Use | Chat LLM | Embeddings | SLA target |
|---------|-----|----------|------------|------------|
| `dev-ollama` | Founder laptop, offline dev | `qwen3:4b` via Ollama | `nomic-embed-text` via Ollama | Best-effort (not sold) |
| `demo-hosted` | Prospect demos, SLA proof | `gpt-4o-mini` (or Azure equivalent) | `text-embedding-3-small` | **Cited query < 30s p95** |
| `pilot-hosted` | First paid pilots (default) | Same as demo-hosted | Same | **Cited query < 30s p95** |
| `pilot-private-gpu` | Customer forbids cloud LLM | 8B+ via Ollama/vLLM on GPU VPS | Local embedding model | **< 30s** with GPU sizing |

Rules:

1. **Ollama is dev-only** for the default product story; demos that prospects see should use `demo-hosted` unless explicitly a "local-only" niche demo.
2. **Paid pilots default to `pilot-hosted`** (OpenAI or Azure OpenAI-compatible).
3. The MVP repo must run **`dev-ollama` without paid APIs** for offline development.
4. Config lives in `config/inference/` — Kotaemon Resources are set from profile docs, not tribal knowledge.

### 1.6 Enterprise architecture decisions (implement in v0 as docs + stubs)

These decisions are **fixed in the PDR** and reflected in repo layout, demo script, and Steps 24–31:

1. **Query SLA** — After indexing, live "where is X?" with citation: **< 30 seconds p95** on `demo-hosted` / `pilot-hosted` profiles.
2. **Inference strategy** — OpenAI/Azure default for demo and pilot; Ollama for dev; private GPU as optional pilot profile.
3. **Product posture** — **Search-first + citations**; chat synthesis is secondary; demo script leads with source list.
4. **Data plane** — v0: manual upload; Phase 2: connectors behind `docs/DATA_PLANE.md` + `connectors/` stubs.
5. **Control plane** — v0: Kotaemon auth + pilot basic auth; Phase 2: SSO, doc ACLs, audit logs — documented in `docs/CONTROL_PLANE.md`.
6. **Tenancy** — Phase 1: **one VPS per customer**; Phase 2: optional multi-tenant SaaS — `docs/TENANCY.md`.
7. **Platform bet** — **Kotaemon as engine** through Phase 1; thin adapter layer so UI/API can migrate — `docs/PLATFORM.md`.

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
18. Inference profiles under `config/inference/` (dev-ollama, demo-hosted, pilot-hosted).
19. Enterprise architecture docs (PRODUCT_ARCHITECTURE, DATA_PLANE, CONTROL_PLANE, TENANCY, PLATFORM).
20. Connector stubs under `connectors/` and query SLA benchmark script.
21. Search-first demo script and hosted-profile SLA acceptance.

### 2.2 Out of scope for v0 (implementation)

Do not **implement** these in v0 (docs + stubs only):

1. Live Slack history ingestion.
2. Live Google Drive / Confluence API sync.
3. Live Jira / Zendesk API sync.
4. SSO/SAML product integration.
5. Document-level enterprise ACLs beyond Kotaemon defaults.
6. Audit log pipeline (document format + hook points only).
7. Billing and self-serve signup.
8. Multi-tenant SaaS control plane.
9. Custom RAG app UI (Kotaemon UI in v0).
10. Custom vector search implementation.
11. Fine-tuning.
12. Agents that take actions in customer systems.
13. Browser extension and mobile app.

### 2.3 In scope for v0 (architecture only)

These **must** exist in v0 as documentation, config profiles, demo behavior, or empty stubs:

1. Inference profiles (`dev-ollama`, `demo-hosted`, `pilot-hosted`).
2. Query SLA benchmark script and demo acceptance (< 30s cited query on hosted profile).
3. Search-first demo script (sources before synthesis).
4. `docs/PRODUCT_ARCHITECTURE.md` — all seven enterprise dimensions.
5. `docs/DATA_PLANE.md` + `connectors/README.md` stub per connector family.
6. `docs/CONTROL_PLANE.md` — SSO, permissions, audit roadmap.
7. `docs/TENANCY.md` — VPS-per-customer now, multi-tenant later.
8. `docs/PLATFORM.md` — Kotaemon-as-engine, migration criteria.

### 2.4 Future scope after first pilot (Phase 2 enterprise)

**Detailed conversion roadmap:** see `Overview/Enterprise_Conversion_Plan.md`.

Phase 2 implements Glean-shaped capabilities on the v0 architecture:

1. Google Drive and Confluence selected-source connectors.
2. Slack bot as **interface** (and optional export ingestion).
3. Jira/Zendesk CSV templates (v0) → live APIs (Phase 2).
4. SSO/SAML (Okta, Azure AD) in front of app.
5. Document-level permissions synced from source systems.
6. Immutable audit log for queries and source access.
7. Usage analytics and saved answer library.
8. Multi-customer managed hosting or self-serve SaaS (optional).
9. Replace or wrap Kotaemon UI if adapter boundaries require it.

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

As the founder/seller, I want to run a **search-first** demo on a **pre-indexed** KB with **cited sources in under 30 seconds** and show the enterprise roadmap (connectors, SSO, tenancy) without claiming we are a full Glean clone today.

Acceptance:

- `demo-hosted` profile configured; `benchmark_query_sla.sh` passes.
- Demo script leads with "which document / where in doc" questions.
- Citations and source preview visible before long synthesis.
- `docs/PRODUCT_ARCHITECTURE.md` supports a 2-minute architecture walkthrough.

---

## 5. Product flow

### 5.1 Admin setup flow

**Development (`dev-ollama`):**

1. Clone repo; install Docker and Ollama.
2. Run `./scripts/setup_ollama.sh` and `./scripts/preflight.sh`.
3. `docker compose up -d`; open `http://localhost:7860`.
4. Apply `config/inference/dev-ollama.example.yml` in Kotaemon Resources.
5. Create collection, upload docs, apply prompt pack; run eval questions.

**Prospect demo (`demo-hosted`) — required before external demos:**

1. Pre-index `sample-data/support/*` (batch; not during live demo).
2. Apply `config/inference/demo-hosted.example.yml` (OpenAI/Azure API keys in env).
3. Run `./scripts/benchmark_query_sla.sh` — p95 ≤ 30s.
4. Run `docs/DEMO_SCRIPT.md` (search-first lookup questions, then policy Q&A).
5. Walk through `docs/PRODUCT_ARCHITECTURE.md` for Phase 2 (connectors, SSO, tenancy).

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

### 7.0 Design principle

**Same repo, same Kotaemon engine, swappable configuration per layer.** No custom RAG in v0. Every enterprise capability has a named extension point in docs or `config/` so Phase 2 adds modules — not a fork.

```text
                    ┌─────────────────────────────────────┐
                    │  Control plane (auth, SSO, audit)   │  Phase 1: basic auth + Kotaemon users
                    └─────────────────────────────────────┘
                    ┌─────────────────────────────────────┐
                    │  Product UI (search-first, chat)    │  Phase 0–1: Kotaemon Gradio
                    └─────────────────────────────────────┘
                    ┌─────────────────────────────────────┐
                    │  Engine (retrieval, cite, index)    │  Phase 0–1: Kotaemon
                    └─────────────────────────────────────┘
                    ┌─────────────────────────────────────┐
                    │  Inference (LLM + embeddings)       │  Profiles: dev-ollama | hosted | GPU
                    └─────────────────────────────────────┘
                    ┌─────────────────────────────────────┐
                    │  Data plane (ingest → index)        │  v0: upload; Phase 2: connectors
                    └─────────────────────────────────────┘
                    ┌─────────────────────────────────────┐
                    │  Tenancy (instance isolation)       │  Phase 1: 1 VPS/customer
                    └─────────────────────────────────────┘
```

### 7.1 Query SLA

**Product SLA (demo + pilot profiles):**

- **Indexing:** batch/background; duration unbounded for v0; operators index, agents do not wait on upload during calls.
- **Live query:** user question → ranked sources + citation snippet visible in UI → optional short answer: **< 30 seconds p95** end-to-end on `demo-hosted` and `pilot-hosted`.
- **Measurement:** `scripts/benchmark_query_sla.sh` runs a fixed set of eval questions against the configured profile; fails CI/manual gate if p95 > 30s.

**Not a v0 SLA:** `dev-ollama` on CPU laptop (best-effort only).

Demo acceptance must include at least one timed "where is X?" question showing sources within SLA on the **hosted demo profile** (or documented GPU profile).

### 7.2 Inference strategy

| Profile | When | LLM | Embeddings | Base URL (from container) |
|---------|------|-----|------------|---------------------------|
| `dev-ollama` | Local dev, no API keys | `qwen3:4b` | `nomic-embed-text` | `http://host.docker.internal:11434/v1/` |
| `demo-hosted` | Prospect demos | `gpt-4o-mini` | `text-embedding-3-small` | `https://api.openai.com/v1/` or Azure OpenAI URL |
| `pilot-hosted` | Paid pilots (default) | same | same | customer-approved endpoint |
| `pilot-private-gpu` | No cloud LLM | 8B+ instruct on GPU VPS | local embed model | `http://127.0.0.1:11434/v1/` on VPS |

Kotaemon Resources use vendor **ChatOpenAI** with YAML from `config/inference/<profile>.example.yml`.

Rules:

1. Never sell `dev-ollama` CPU latency as production behavior.
2. Store API keys in env / secrets, never in git.
3. Re-index when switching embedding models (document in setup docs).

### 7.3 Product posture (search-first + citations)

**Primary job:** "Which document contains X, and where?"

UX order for demo and pilot training:

1. User asks a narrow lookup question.
2. UI shows **retrieved sources / citations first** (open PDF preview, snippet).
3. Optional synthesized internal answer and customer-ready reply.

Prompt packs must not encourage long essays before sources are shown. Demo script (`docs/DEMO_SCRIPT.md`) leads with 2 lookup questions before policy synthesis questions.

Disable or de-emphasize heavy "auto-summary on upload" in demo guidance (slow, not core value).

### 7.4 Data plane

**v0 (implement):** manual upload via Kotaemon UI; `scripts/prepare_docs.py` for messy exports; CSV ticket templates.

**v0 (stub):** `connectors/README.md` defines future connector contract:

```text
connector_id → list_objects() → fetch_object() → normalize → kotaemon_ingest_path
```

Planned Phase 2 sources (document only in v0): Google Drive, SharePoint, Confluence, Slack export, Jira, Zendesk.

**Indexing model:** ingest is **async/batch**; search index is **always-on** after job completes. Agents query a stable index, not raw uploads.

### 7.5 Control plane

| Capability | v0 | Phase 2 |
|------------|-----|---------|
| App login | Kotaemon default user (`admin`) | SSO/SAML |
| Edge auth | Caddy basic auth on pilot VPS | Same + customer IdP |
| Document permissions | Collection-level (Kotaemon) | Sync ACLs from source systems |
| Audit | Not implemented | Log: who, query, sources shown, timestamp |
| Secrets | `.env`, not committed | Vault / provider secrets |

`docs/CONTROL_PLANE.md` describes mapping without implementing SSO in v0.

### 7.6 Tenancy

**Phase 1 (default):** one **dedicated VPS per customer** — separate `ktem_app_data`, domain, secrets, inference keys. No shared index across customers.

**Phase 2 (optional):** multi-tenant SaaS — single control plane, isolated indices per `tenant_id`; **not** required for first paid pilot.

**Demo:** founder instance only; never mix customer and demo data in one `ktem_app_data`.

### 7.7 Platform bet (Kotaemon)

**Phase 0–1:** Kotaemon is the **engine + UI** — document QA, hybrid retrieval, citations, PDF highlight. Do not rebuild.

**Adapter rule:** all product-specific logic lives in this repo (`prompt-packs/`, `config/`, `docs/`, scripts) — **not** a Kotaemon fork.

**Migration triggers** (document in `docs/PLATFORM.md`): need custom search UI, SSO at scale, connector orchestration, or SLA features Kotaemon cannot configure. Then add a thin API or new UI **on top of the same index**, or export index format and migrate.

### 7.8 Runtime deployment

Use the same app and repo across modes. **Inference profile + tenancy** change; engine stays Kotaemon.

#### 7.8.1 Local development runtime

- Profile: `dev-ollama`.
- Ollama on host port 11434; Docker Kotaemon at `http://localhost:7860`.
- No VPS or paid API required.

#### 7.8.2 Demo / prospect runtime

- Profile: `demo-hosted` (recommended) or GPU VPS with `pilot-private-gpu`.
- Same Docker compose; different Kotaemon Resource YAML from `config/inference/`.
- Must pass SLA benchmark before external demos.

#### 7.8.3 First-customer pilot runtime

- Profile: `pilot-hosted` (default).
- One VPS per customer; Caddy HTTPS; basic auth; customer-specific `ktem_app_data` path.
- Raw port 7860 not public.

Deployment order:

1. Founder local — dev and internal validation (`dev-ollama`).
2. Dedicated VPS per customer — paid pilot (`pilot-hosted`).
3. Customer-owned server/VPN — only when required.
4. Multi-tenant SaaS — Phase 2 only.

### 7.9 Storage

`./ktem_app_data:/app/ktem_app_data` locally.

Pilots: `/opt/support-knowledge-bot/customers/<customer_id>/ktem_app_data`.

No mixed customer data in one folder.

### 7.10 Security assumptions for v0

1. Fake data for internal demos.
2. Approved docs only for pilots; written permission.
3. No full workspace dumps; no Slack DMs.
4. Customer-specific folders and VPS isolation.
5. HTTPS + basic auth on pilot VPS; no public 7860.
6. Retrieved chunks sent to cloud LLM only under `pilot-hosted` — disclose in data handling doc.

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

  config/
    inference/
      dev-ollama.example.yml
      demo-hosted.example.yml
      pilot-hosted.example.yml
      pilot-private-gpu.example.yml
      README.md

  connectors/
    README.md
    google_drive/.gitkeep
    confluence/.gitkeep
    sharepoint/.gitkeep

  scripts/
    preflight.sh
    setup_ollama.sh
    smoke_test_ollama.sh
    benchmark_query_sla.sh
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
    PRODUCT_ARCHITECTURE.md
    INFERENCE_PROFILES.md
    DATA_PLANE.md
    CONTROL_PLANE.md
    TENANCY.md
    PLATFORM.md
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

Follow **Steps 1–31** one by one in Cursor. Do not move to the next step until the acceptance checks pass.

- **Steps 1–22:** MVP wrapper, Kotaemon, dev-ollama, docs, prompts, pilot compose.
- **Steps 23–31:** Enterprise-ready architecture — inference profiles, SLA benchmark, connector/control/tenancy/platform docs, search-first demo, full acceptance (dev + hosted demo).

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
Create a repo for a Glean-shaped support knowledge bot MVP (search-first, cited answers, <30s query SLA on hosted profile). This is a wrapper around Kotaemon — not a custom RAG app.

Create the folder structure in PDR §8, including:
- config/inference/ with profile example YAML files
- connectors/ stubs per PDR §7.4
- docs/PRODUCT_ARCHITECTURE.md, DATA_PLANE.md, CONTROL_PLANE.md, TENANCY.md, PLATFORM.md, INFERENCE_PROFILES.md (placeholders OK)
- scripts/benchmark_query_sla.sh (placeholder OK)

Do not implement custom RAG code. README must state: Kotaemon = engine; Ollama = dev-only; demo/pilot = hosted inference profiles by default.
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

- Output includes `docker-compose.yml`, `docker-compose.pilot.yml`, `Caddyfile.example`, `.env.pilot.example`.
- Output includes `config/inference/dev-ollama.example.yml` and `demo-hosted.example.yml`.
- Output includes `connectors/README.md` and `docs/PRODUCT_ARCHITECTURE.md`.
- Output includes `scripts/setup_ollama.sh` and `scripts/benchmark_query_sla.sh`.
- Output includes `prompt-packs/support_v1.md` and `sample-data/support/01_refund_policy.md`.
- README states Kotaemon = engine, Ollama = dev-only, demo/pilot = hosted profiles.
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

Make **dev-only** local model setup easy (`dev-ollama` profile). Production demos and pilots use hosted inference per §7.2 — not this script alone.

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

Make the manual UI configuration step explicit for **all inference profiles** (not Ollama-only).

### Cursor prompt

```text
Write docs/KOTAEMON_MODEL_SETUP.md.

Point to config/inference/*.example.yml and docs/INFERENCE_PROFILES.md as source of truth.

For each profile document ChatOpenAI YAML for Kotaemon Resources:

1. dev-ollama — Ollama on host; base_url http://host.docker.internal:11434/v1/; qwen3:4b + nomic-embed-text; dev-only.
2. demo-hosted — OpenAI or Azure; gpt-4o-mini + text-embedding-3-small; required for prospect demos and SLA.
3. pilot-hosted — same as demo-hosted for customer VPS.
4. pilot-private-gpu — Ollama on VPS GPU; larger instruct model.

Include: re-index when changing embedding model; disable heavy LLM reranking on weak hardware; start new conversation after model change; Ollama must not be sold as production latency.
```

### Expected output

A setup doc focused on profile-based model configuration.

### Acceptance checks

Manual read check:

- Documents dev-ollama and demo-hosted at minimum.
- Links to config/inference/ examples.
- States demo/pilot default is hosted, not laptop Ollama.

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

Make README the file a founder opens first, including enterprise architecture and inference profiles.

### Cursor prompt

```text
Rewrite README.md as the main control panel.

Sections:
1. What this is (Glean-shaped: search-first, cited answers, <30s query SLA on hosted profile).
2. What this is not (not full Glean in v0; not custom RAG).
3. Architecture map — link to docs/PRODUCT_ARCHITECTURE.md and the seven layers (SLA, inference, posture, data, control, tenancy, platform).
4. Quick start — dev path (dev-ollama) vs demo path (demo-hosted).
5. Inference profiles — link to config/inference/ and docs/INFERENCE_PROFILES.md.
6. Commands (Makefile + scripts).
7. Search-first demo flow — link to docs/DEMO_SCRIPT.md.
8. Prompt packs.
9. Customer pilot flow and tenancy (one VPS per customer).
10. Phase 2 roadmap links (DATA_PLANE, CONTROL_PLANE, PLATFORM).
11. Troubleshooting and license notes.

Quick start (dev):
- ./scripts/setup_ollama.sh
- ./scripts/preflight.sh
- docker compose up -d

Quick start (prospect demo):
- Set OPENAI_API_KEY (or Azure) per config/inference/demo-hosted.example.yml
- Apply profile in Kotaemon Resources per docs/INFERENCE_PROFILES.md
- Pre-index sample-data; run ./scripts/benchmark_query_sla.sh

State clearly: Ollama = dev-only; paid demos/pilots default to hosted profile.
```

### Expected output

README is useful and concise.

### Acceptance checks

Manual read check:

- A new user understands what to do first.
- It does not oversell the project as custom IP.
- It links to all docs.

---

## Step 23: Dev-profile full stack acceptance

### Goal

Prove the **dev-ollama** path works locally (offline development). This is not the prospect-demo acceptance gate.

### Manual steps

Run:

```bash
./scripts/setup_ollama.sh
./scripts/preflight.sh
docker compose up -d
```

Apply `config/inference/dev-ollama.example.yml` in Kotaemon Resources. Upload `sample-data/support/*`, apply `prompt-packs/support_v1.md`, run eval questions from `evals/support_eval_questions.jsonl`.

### Pass conditions

- App loads at localhost:7860.
- Ollama chat and embeddings work.
- Sample docs index; cited answers for refund and SSO questions.
- Unsupported question refused.
- No paid API key required.

---

## Step 24: Product architecture doc

### Goal

Document all seven enterprise dimensions in one place so every build step aligns with the Glean-shaped target.

### Cursor prompt

```text
Implement docs/PRODUCT_ARCHITECTURE.md.

Include:
1. North star (search-first, cited answer <30s after index).
2. Layer diagram (data plane, inference, engine, UI, control, tenancy).
3. Phase 0 / 1 / 2 table matching PDR §0.
4. Cross-links to DATA_PLANE, CONTROL_PLANE, TENANCY, PLATFORM, INFERENCE_PROFILES.
5. Explicit non-goals for v0 vs Phase 2.
6. How demo and pilot differ from dev-ollama.
```

### Acceptance checks

- All seven dimensions from PDR §1.6 are documented.
- Phase map is clear for a non-engineer founder.

---

## Step 25: Inference profiles

### Goal

Make inference swappable without code changes.

### Cursor prompt

```text
Implement config/inference/README.md and example YAML files:
- dev-ollama.example.yml
- demo-hosted.example.yml
- pilot-hosted.example.yml
- pilot-private-gpu.example.yml

Each file must list: profile name, use case, Kotaemon vendor (ChatOpenAI), api_key env var name, base_url, llm model, embedding model, notes on re-indexing when switching embeddings.

Implement docs/INFERENCE_PROFILES.md with copy-paste steps for Kotaemon Resources UI.

Add .env.example entries for OPENAI_API_KEY, AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_API_KEY (commented, not required for dev).
```

### Acceptance checks

- Four profile files exist and match PDR §7.2.
- INFERENCE_PROFILES.md explains dev vs demo vs pilot.

---

## Step 26: Query SLA benchmark script

### Goal

Enforce cited-query latency target on hosted profile.

### Cursor prompt

```text
Implement scripts/benchmark_query_sla.sh.

Requirements:
- Read questions from evals/support_eval_questions.jsonl (or a dedicated sla subset).
- For each question: time end-to-end request to configured inference endpoint (chat completions with retrieval context OR document Kotaemon API if unavailable — at minimum time LLM round-trip after manual note in doc).
- Accept INFERENCE_PROFILE env or argument: dev-ollama | demo-hosted.
- Print per-question latency and p95.
- Exit 0 if p95 <= 30 seconds on demo-hosted when API key present; exit 0 with WARNING on dev-ollama; exit 1 if demo-hosted p95 > 30.

Document usage in docs/ACCEPTANCE_TESTS.md.
```

### Acceptance checks

```bash
bash -n scripts/benchmark_query_sla.sh
```

- Script runs without syntax errors.
- Documented threshold: 30s p95 on demo-hosted.

---

## Step 27: Data plane docs and connector stubs

### Goal

v0 upload path + Phase 2 connector contracts without implementing APIs.

### Cursor prompt

```text
Implement docs/DATA_PLANE.md and connectors/README.md.

DATA_PLANE.md:
- v0: manual upload, prepare_docs.py, CSV exports.
- Indexing is batch/async; agents query stable index.
- Phase 2 connector interface: list, fetch, normalize, ingest.
- Table of planned connectors: google_drive, confluence, sharepoint, slack_export, jira, zendesk.

Create empty stub dirs: connectors/google_drive/, connectors/confluence/, connectors/sharepoint/ each with README.md one paragraph on future scope.
```

### Acceptance checks

- DATA_PLANE.md distinguishes ingest vs query.
- Each connector stub dir exists.

---

## Step 28: Control plane and tenancy docs

### Goal

Document SSO, permissions, audit, and tenancy without implementing enterprise auth in v0.

### Cursor prompt

```text
Implement docs/CONTROL_PLANE.md and docs/TENANCY.md.

CONTROL_PLANE.md:
- v0: Kotaemon users, pilot Caddy basic auth.
- Phase 2: SSO/SAML, document ACLs, audit log fields (who, query, sources, timestamp).
- Data handling note when pilot-hosted sends chunks to cloud LLM.

TENANCY.md:
- Phase 1: one VPS per customer, folder layout, no shared index.
- Phase 2: optional multi-tenant SaaS diagram.
- Demo instance isolation rules.
```

### Acceptance checks

- Both docs exist and match PDR §7.5–7.6.

---

## Step 29: Platform adapter doc

### Goal

Lock Kotaemon as engine and define when to migrate UI/API.

### Cursor prompt

```text
Implement docs/PLATFORM.md.

Include:
- Kotaemon responsibilities (retrieval, citations, PDF preview, collections).
- What lives in this wrapper repo only (prompts, profiles, onboarding, scripts).
- Adapter boundary: no fork of Kotaemon core in v0.
- Migration triggers: custom search UI, enterprise SSO, connector orchestration, SLA features Kotaemon cannot meet.
- Phase 2 options: wrap Kotaemon API, export index, or replace UI only.
```

### Acceptance checks

- Migration triggers are explicit and testable.

---

## Step 30: Search-first demo script and hosted demo acceptance

### Goal

Demo reflects enterprise product posture and SLA, not slow chat-first laptop behavior.

### Cursor prompt

```text
Rewrite docs/DEMO_SCRIPT.md.

Structure:
1. Prerequisites: pre-indexed collection, demo-hosted profile applied, benchmark_query_sla.sh passed.
2. Architecture walkthrough (2 min): search-first, citations, Phase 2 connectors/SSO on roadmap — point to PRODUCT_ARCHITECTURE.md.
3. Search-first questions FIRST (show sources before reading long answer):
   - "Which document covers SSO group sync issues?"
   - "Where is the refund window for annual plans documented?"
4. Then policy questions with citations.
5. One unsupported question.
6. Explicitly skip or de-emphasize waiting for auto-summary on upload.

Update docs/ACCEPTANCE_TESTS.md with "Hosted demo acceptance" section mirroring these steps and 30s SLA requirement.
```

### Acceptance checks

- Demo script leads with lookup/source questions.
- ACCEPTANCE_TESTS.md includes hosted demo + SLA gate.

---

## Step 31: Full enterprise-ready MVP acceptance

### Goal

Prove dev path, architecture artifacts, and hosted demo path are all complete.

### Manual steps

**A. Dev path** — Step 23 pass.

**B. Architecture** — confirm exist and are non-empty:

- docs/PRODUCT_ARCHITECTURE.md
- docs/INFERENCE_PROFILES.md
- docs/DATA_PLANE.md, CONTROL_PLANE.md, TENANCY.md, PLATFORM.md
- config/inference/*.example.yml
- connectors/README.md

**C. Hosted demo path** (required before external prospects):

1. Apply `demo-hosted` profile in Kotaemon.
2. Pre-index `sample-data/support/*`.
3. Run `./scripts/benchmark_query_sla.sh` with demo-hosted — p95 ≤ 30s.
4. Run demo script once; sources visible before synthesis on lookup questions.

### Pass conditions

- All Step 1–30 artifacts present.
- Dev-ollama works without paid API.
- Hosted demo meets SLA and search-first script.
- Founder can explain Phase 2 (connectors, SSO, tenancy) using docs only.

---

## 10. Prompt pack content requirements

### 10.1 Support prompt pack exact template

The support prompt pack should include this or a close variant:

```text
You are an internal support answer assistant for a growing B2B software company.

Your job is to answer support-team questions using only the retrieved source documents. You must not invent company policy, pricing, security, billing, legal, product, or escalation details.

Rules:
0. Search-first: list Sources used (document name + section/snippet) before Internal answer when sources are available.
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

### 11.1 Good enough for internal testing (dev-ollama)

- Runs locally with Ollama; no paid API.
- Ingests sample docs; cited answers; refuses unsupported questions.
- Architecture docs and inference profiles exist (Steps 24–29).

### 11.2 Good enough for first prospect demo (demo-hosted)

- **Pre-indexed** sample KB; agents do not wait on upload during demo.
- **Search-first demo script** completed; lookup questions show sources first.
- **p95 query latency ≤ 30 seconds** on `benchmark_query_sla.sh` with demo-hosted profile.
- At least 5 answerable questions with correct citations.
- At least 1 unsupported question refused.
- Seller explains Phase 2 roadmap (connectors, SSO) using PRODUCT_ARCHITECTURE.md — not "we only do local Ollama."

### 11.3 Good enough for first paid pilot (pilot-hosted)

- All 11.2 criteria on customer VPS with `pilot-hosted` profile (or documented GPU private profile).
- Customer approved docs only; 20 known questions; ≥70% acceptable after cleanup.
- One VPS per customer; data isolated; HTTPS; no public 7860.
- DATA_HANDLING.md signed off if cloud LLM processes retrieved chunks.

---

## 12. Fallbacks and known risks

### 12.1 Latency and model quality

Risk:

- `dev-ollama` on CPU is too slow for live "where is X?" and must not be sold as production.
- qwen3:4b may produce weaker answers than hosted models.

Mitigation:

- **Demos and pilots use `demo-hosted` / `pilot-hosted` by default** (§7.2).
- Run `benchmark_query_sla.sh` before external demos.
- Search-first UX; curated docs; strict prompts.
- `pilot-private-gpu` only when customer forbids cloud LLM.

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

"We deploy a private, search-first knowledge assistant for your support team — find the right document and cited passage in seconds after your docs are indexed. Cited internal answers, customer-ready replies, and escalation guidance. Connectors and SSO on the roadmap; v0 uses your approved docs without a full workspace integration project."

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

Do not build a new RAG product unless explicitly instructed later (see `docs/PLATFORM.md` for migration triggers).

The MVP is successful if a founder can:

1. Run **dev-ollama** locally for development.
2. Run **demo-hosted** for prospects with **p95 cited query < 30s**.
3. Launch Kotaemon and pre-index approved docs (batch ingest, not live-call upload).
4. Deliver **search-first** demos with visible citations.
5. Explain enterprise roadmap (data plane, control plane, tenancy) from docs without hand-waving.
6. Run a first paid pilot on a **dedicated VPS** with `pilot-hosted` profile.

Prioritize architecture boundaries, inference profiles, SLA benchmark, and demo script over custom code. Implement Steps 24–31 so Phase 2 enterprise features plug in — do not fork Kotaemon in v0.

---

## 15. Reference notes

These references were used when choosing the stack. Re-check before production use:

- Kotaemon GitHub/docs: document QA UI, Docker images, Ollama support, hybrid retrieval, citations, PDF preview/highlights.
- Kotaemon local model setup docs: Ollama via OpenAI-compatible endpoint, `host.docker.internal` when running through Docker.
- Ollama docs: OpenAI-compatible local API and embeddings.
- Microsoft MarkItDown: document-to-Markdown conversion helper for LLM/RAG pipelines.

