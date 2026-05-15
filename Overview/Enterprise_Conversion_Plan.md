# Enterprise Conversion Plan

Version: 1.0  
Date: 2026-05-15  
Status: Planning (companion to PDR v0.3)  
Related: `Overview/finalized_local_first_support_kb_pdr.md` (build steps 1–31)

---

## 1. Purpose

This document describes **how the Support Knowledge Bot MVP becomes a Glean-shaped enterprise product** without throwing away the wrapper repo or forking Kotaemon prematurely.

**North star:** After batch indexing, a user asks *where is X documented?* and sees **accurate citations** (document + location) with optional synthesis in **under 30 seconds p95**.

**What we are converting toward:**

- Search-first workplace knowledge (not chat-first hobby RAG).
- Connectors + permissions + audit (not upload-only forever).
- Production inference (hosted or private GPU), not laptop Ollama.
- Isolated customer deployments first; optional multi-tenant SaaS later.

**What we are not claiming in v0:** Full Glean parity (connector marketplace, global SaaS, full ACL sync on day one).

---

## 2. Phase map

| Phase | Name | Customer-facing | Build focus | Exit criteria |
|-------|------|-----------------|-------------|---------------|
| **0** | MVP + architecture | Internal / founder | PDR Steps 1–31; Kotaemon wrapper; inference profiles; docs + stubs | Step 31 pass: dev-ollama + demo-hosted SLA + architecture artifacts |
| **1** | Paid pilot | 1 customer, 5–25 users | `pilot-hosted` on dedicated VPS; curated docs; search-first training | 30-day pilot metrics; ≥70% known-question quality; customer renewal intent |
| **2** | Enterprise pilot+ | 2–5 customers | Connectors v1, SSO, audit log, doc ACLs where required | Customers use connectors or scheduled sync; SSO in production |
| **3** | Enterprise platform | Many customers | Optional multi-tenant SaaS OR standardized private cloud kit | Repeatable deploy; ops runbooks; optional custom UI |

Phases **0–1** are defined in the PDR. **This plan owns Phases 2–3** in detail.

---

## 3. Layer-by-layer conversion

The MVP intentionally separates concerns so each layer can upgrade independently.

```text
┌─────────────────────────────────────────────────────────────┐
│ Control plane    v0: Kotaemon users + Caddy basic auth       │
│                  →  SSO, ACLs, audit, secrets vault         │
├─────────────────────────────────────────────────────────────┤
│ Product UI       v0: Kotaemon Gradio (search-first UX)     │
│                  →  Optional search-first shell / API       │
├─────────────────────────────────────────────────────────────┤
│ Engine           v0–2: Kotaemon (retrieval, cite, index)   │
│                  →  Same engine OR export index + migrate   │
├─────────────────────────────────────────────────────────────┤
│ Inference        v0 dev: Ollama | demo/pilot: hosted API    │
│                  →  Per-tenant profile + GPU option         │
├─────────────────────────────────────────────────────────────┤
│ Data plane       v0: manual upload + CSV                   │
│                  →  Connectors (Drive, Confluence, …)       │
├─────────────────────────────────────────────────────────────┤
│ Tenancy          v0–1: one VPS / one ktem_app_data / cust  │
│                  →  Optional multi-tenant control plane     │
└─────────────────────────────────────────────────────────────┘
```

Repo artifacts that **must exist after PDR Step 31** (enables conversion):

| Artifact | Role in conversion |
|----------|-------------------|
| `docs/PRODUCT_ARCHITECTURE.md` | Single map of layers and phases |
| `config/inference/*.example.yml` | Swap models without code changes |
| `docs/DATA_PLANE.md` + `connectors/*` | Connector contract + per-source stubs |
| `docs/CONTROL_PLANE.md` | SSO / audit / ACL roadmap |
| `docs/TENANCY.md` | VPS-per-customer → SaaS path |
| `docs/PLATFORM.md` | When to keep vs replace Kotaemon UI |
| `scripts/benchmark_query_sla.sh` | Regression gate on latency |

---

## 4. Query SLA (conversion requirement)

### 4.1 SLA definition

| Operation | User waits? | Target |
|-----------|-------------|--------|
| Indexing / connector sync | No (batch) | Complete within agreed maintenance window |
| Lookup + citations | Yes | **≤ 30s p95** end-to-end |
| Full synthesis answer | Yes | Same request; sources shown first in UX |

### 4.2 How we get there by phase

| Phase | Approach |
|-------|----------|
| 0–1 | `demo-hosted` / `pilot-hosted` (e.g. `gpt-4o-mini` + `text-embedding-3-small`) |
| 1 (regulated) | `pilot-private-gpu` on sized GPU VPS |
| 2+ | Same profiles per tenant; optional regional Azure OpenAI |

### 4.3 Ongoing enforcement

- Run `benchmark_query_sla.sh` before every external demo and after infra/model changes.
- Add eval questions to `evals/support_eval_questions.jsonl` as customers onboard.
- Do **not** regress to selling `dev-ollama` on CPU as "production."

---

## 5. Inference strategy (conversion)

### 5.1 Principles

1. **Configuration, not code** — inference lives in `config/inference/` and env secrets.
2. **Dev ≠ prod** — Ollama on laptop is `dev-ollama` only.
3. **Disclose data flow** — `pilot-hosted` sends retrieved chunks to cloud LLM; document in `DATA_HANDLING.md` and contracts.

### 5.2 Conversion steps

| Step | Action | When |
|------|--------|------|
| E-INF-1 | Ship profile YAML + `INFERENCE_PROFILES.md` (PDR Step 25) | Phase 0 |
| E-INF-2 | Default all prospect demos to `demo-hosted` | Phase 0 |
| E-INF-3 | Per-customer API keys on pilot VPS | Phase 1 |
| E-INF-4 | Offer `pilot-private-gpu` in security questionnaire | Phase 1+ |
| E-INF-5 | Azure OpenAI / private endpoint for EU/customer policy | Phase 2 |

### 5.3 Re-index rule

Changing **embedding** model requires re-indexing that tenant’s collections. Document in onboarding; automate check in preflight (compare profile vs index metadata when available).

---

## 6. Product posture (search-first)

### 6.1 UX conversion

| Today (avoid selling) | Enterprise default |
|----------------------|-------------------|
| Wait for upload + auto-summary | Pre-indexed KB; admin/sync job |
| Long chat answer first | **Sources panel first**, then synthesis |
| "AI chatbot" framing | "Find the doc and cited passage" |

### 6.2 Conversion steps

| Step | Action | When |
|------|--------|------|
| E-UX-1 | Demo script: lookup questions before policy questions (PDR Step 30) | Phase 0 |
| E-UX-2 | Prompt packs: rule 0 — list sources before internal answer | Phase 0 |
| E-UX-3 | Train pilots: agents open citation preview, not only chat text | Phase 1 |
| E-UX-4 | Optional: custom search results page reading same index (Phase 3) | If Kotaemon UI limits search UX |

---

## 7. Data plane (connectors)

### 7.1 v0 baseline

- Manual upload + `prepare_docs.py` + CSV exports (Jira/Zendesk templates).
- Indexing is **async**; agents query stable index.

### 7.2 Connector contract (implement in Phase 2)

Each connector under `connectors/<name>/` implements:

```text
list_objects(cursor) → [{ id, path, mime, modified_at, acl_hint }]
fetch_object(id) → normalized_file_path
normalize() → markdown or text + metadata
ingest() → push to Kotaemon collection / watch folder
```

Scheduled sync (cron or worker) — not live on every query.

### 7.3 Priority order (recommended)

| Priority | Source | Rationale |
|----------|--------|-----------|
| 1 | Google Drive / SharePoint | Where SMBs store SOPs |
| 2 | Confluence | Common for internal KB |
| 3 | Zendesk / Jira | Ticket history (export first, API second) |
| 4 | Slack | Interface first; export ingestion second |

### 7.4 Conversion steps

| Step | Action | When |
|------|--------|------|
| E-DATA-1 | `DATA_PLANE.md` + `connectors/README.md` (PDR Step 27) | Phase 0 |
| E-DATA-2 | Drive connector MVP (read-only, selected folders) | Phase 2a |
| E-DATA-3 | Confluence connector MVP | Phase 2b |
| E-DATA-4 | Incremental sync + delete handling | Phase 2c |
| E-DATA-5 | ACL hints passed to control plane | Phase 2 + E-CTRL-4 |

---

## 8. Control plane (SSO, permissions, audit)

### 8.1 v0 baseline

- Kotaemon login + pilot Caddy basic auth.
- Collection-level access within Kotaemon.

### 8.2 Enterprise target

| Capability | Target behavior |
|------------|-----------------|
| SSO/SAML | Okta / Azure AD in front of app (Caddy auth or app middleware) |
| Document ACLs | User sees only docs their identity can access in source system |
| Audit log | Immutable: `timestamp, user_id, query, collection_ids, source_doc_ids, inference_profile` |
| Secrets | Vault or cloud secret manager per tenant |

### 8.3 Conversion steps

| Step | Action | When |
|------|--------|------|
| E-CTRL-1 | `CONTROL_PLANE.md` roadmap (PDR Step 28) | Phase 0 |
| E-CTRL-2 | HTTPS + basic auth on every pilot VPS | Phase 1 |
| E-CTRL-3 | SSO reverse-proxy (e.g. OAuth2-proxy + IdP) for one pilot | Phase 2a |
| E-CTRL-4 | ACL filter on retrieval results from connector metadata | Phase 2b |
| E-CTRL-5 | Append-only audit log (file or DB) + export for customer | Phase 2c |

---

## 9. Tenancy

### 9.1 Default through Phase 2

**One VPS per customer:**

```text
/opt/support-knowledge-bot/customers/<customer_id>/
  ktem_app_data/
  .env                    # inference keys, PUBLIC_HOST
  docker-compose override
```

No shared index, no shared secrets, no shared demo data.

### 9.2 Optional Phase 3: multi-tenant SaaS

Only when ops cost of per-VPS deploy hurts margins:

- `tenant_id` on every index object and audit row.
- Control plane provisions namespace; data plane isolated per tenant.
- Still **not** mixing customer corpora in one search index.

### 9.3 Conversion steps

| Step | Action | When |
|------|--------|------|
| E-TEN-1 | `TENANCY.md` + folder conventions (PDR Step 28) | Phase 0 |
| E-TEN-2 | Scripted provision: new customer VPS checklist | Phase 1 |
| E-TEN-3 | Evaluate multi-tenant vs continued VPS-per-customer | Phase 3 gate |

---

## 10. Platform bet (Kotaemon)

### 10.1 Phase 0–2 default

**Keep Kotaemon** as engine + UI. All product IP stays in wrapper repo:

- Prompt packs, inference profiles, onboarding, connectors (when built), evals.

### 10.2 Migration triggers (when to leave or wrap Kotaemon UI)

Consider a new UI or API layer when **two or more** are true:

1. Cannot meet search-first UX (sources-first layout) in Gradio.
2. SSO / ACL integration is fighting Kotaemon user model.
3. Connector orchestration needs background workers Kotaemon does not support.
4. Customer requires white-label UI Kotaemon cannot provide.
5. SLA or scale limits hit on single-container deploy.

### 10.3 Migration paths (prefer in order)

1. **Wrap** — Thin Next.js (or similar) search UI → Kotaemon API / same collections.
2. **Sidecar** — Connectors write to ingest folder; Kotaemon indexes unchanged.
3. **Export** — Chroma/embeddings export (if feasible) → new engine (last resort).

Do **not** fork Kotaemon core until migration triggers are met.

### 10.4 Conversion steps

| Step | Action | When |
|------|--------|------|
| E-PLAT-1 | `PLATFORM.md` with triggers (PDR Step 29) | Phase 0 |
| E-PLAT-2 | Quarterly review: still meeting triggers? | Phase 1+ |
| E-PLAT-3 | Spike: search-only UI on top of existing index | Phase 3 if needed |

---

## 11. End-to-end conversion timeline (suggested)

```text
Phase 0 (now)     PDR Steps 9–31
                  ├── Architecture docs + inference profiles
                  ├── SLA benchmark + search-first demo
                  └── Connector/control/tenancy stubs

Phase 1 (0–3 mo)  First paid pilots
                  ├── pilot-hosted on VPS per customer
                  ├── Pre-index playbook; no live-call upload
                  └── Pilot success metrics (PDR §13.3)

Phase 2a (3–9 mo) Enterprise features — batch 1
                  ├── SSO in front of pilot stack
                  ├── Drive OR Confluence connector
                  └── Audit log v1

Phase 2b (9–15 mo) Enterprise features — batch 2
                  ├── Second connector family
                  ├── ACL-aware retrieval
                  └── Zendesk/Jira API or improved CSV pipeline

Phase 3 (15+ mo)  Platform scale
                  ├── Optional multi-tenant OR hardened private-cloud kit
                  ├── Usage analytics + saved answers
                  └── Custom UI only if migration triggers met
```

Timelines are **suggestions**; gate each batch on paying customer demand and pilot learnings.

---

## 12. What stays the same during conversion

To avoid a rewrite:

1. **Same repo** — wrapper grows; no "v2 repo" unless legally required.
2. **Same engine** — Kotaemon until platform triggers fire.
3. **Same compose base** — `docker-compose.yml` + pilot override + per-customer env.
4. **Same eval set** — extend `evals/support_eval_questions.jsonl`, don't replace.
5. **Same prompt pack format** — versioned `prompt-packs/*_vN.md`.

---

## 13. Commercial narrative shift

| Stage | Pitch |
|-------|--------|
| Phase 0 demo | "Search-first cited answers from your approved docs; enterprise connectors and SSO on the roadmap — here's the architecture." |
| Phase 1 pilot | "Private instance on your VPS; sub-30s lookups after we index your KB; no full IT integration project." |
| Phase 2 enterprise | "Synced from Drive/Confluence with permissions; SSO; audit trail for compliance." |
| Phase 3 | "Managed knowledge platform for support teams — Glean-class outcomes without Glean-scale procurement." |

---

## 14. Risks during conversion

| Risk | Mitigation |
|------|------------|
| Building connectors before pilot proves value | Phase 1 is upload-only; connectors only after paid pilot success |
| Premature multi-tenant SaaS | Stay VPS-per-customer until 5+ customers hurt ops |
| Forking Kotaemon early | Adapter docs + wrapper-only IP |
| Latency regression | SLA script on every release |
| Cloud LLM blocked by customer | `pilot-private-gpu` profile + contract option |

---

## 15. Checklist: ready to call ourselves "enterprise"

Use this before marketing enterprise tier:

- [ ] `demo-hosted` / `pilot-hosted` SLA passes on customer-like corpus size
- [ ] At least one paid pilot completed with documented metrics
- [ ] SSO working on at least one production customer
- [ ] At least one live connector (or scheduled sync) in production
- [ ] Audit log export demonstrated to customer security review
- [ ] Per-customer data isolation verified (no cross-tenant leakage test)
- [ ] `DATA_HANDLING.md` and contracts cover cloud inference if used
- [ ] Runbook: provision VPS, index docs, rotate keys, destroy tenant

---

## 16. Relationship to PDR build steps

| PDR steps | Conversion plan section |
|-----------|-------------------------|
| 24 – Product architecture | §3, §12 |
| 25 – Inference profiles | §5 |
| 26 – SLA benchmark | §4 |
| 27 – Data plane stubs | §7 |
| 28 – Control + tenancy docs | §8, §9 |
| 29 – Platform doc | §10 |
| 30 – Search-first demo | §6 |
| 31 – Full acceptance | Phase 0 exit; gates Phase 1 |

**After Step 31:** Execute Phase 1 pilots, then Phase 2 batches in §11 using this document as the source of truth for enterprise scope.

---

## 17. Document maintenance

- Update this plan when a Phase 2 batch ships or when migration triggers change.
- Keep PDR v0.3 frozen for Phase 0 build; major enterprise scope changes go here first, then optionally a PDR v0.4 if build steps must change.
