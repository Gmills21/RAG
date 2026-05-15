# Support Knowledge Bot

Search-first support knowledge bot MVP: find the right document, cite the
passage, and produce a grounded answer. The hosted demo and pilot profiles target
live cited queries under 30 seconds after documents are already indexed.

This repo is a control panel around Kotaemon, not a new RAG engine. It packages
setup scripts, inference profiles, prompt packs, sample docs, pilot guidance, and
acceptance checks so a founder can demo and pilot a Glean-shaped support KB
without building a custom platform first.

## What This Is

- A Kotaemon-based document QA MVP for approved support docs.
- A search-first workflow: sources and citations matter before synthesis.
- A local dev path using Ollama with no paid API required.
- A demo and pilot path using hosted or customer-approved inference for speed.
- A wrapper repo for prompts, docs, scripts, sample data, and deployment notes.
- A Phase 2-ready architecture direction for connectors, SSO, tenancy, and
  platform migration when the first pilot proves value.

## What This Is Not

- Not full Glean in v0.
- Not a custom RAG backend, vector database, or chat UI.
- Not a live connector marketplace for Slack, Drive, Jira, Zendesk, or
  Confluence.
- Not multi-tenant SaaS.
- Not a reason to upload an entire company workspace into a pilot.

## Architecture Map

The north star is a Glean-shaped product: search-first, cited answers, and a
hosted-profile query SLA of less than 30 seconds p95 after indexing.

Planned architecture source: [PRODUCT_ARCHITECTURE.md](docs/PRODUCT_ARCHITECTURE.md)
(added in the later architecture step; until then, use this map and the PDR).

The seven architecture dimensions are:

| Layer | v0 stance | Roadmap link |
|---|---|---|
| Query SLA | Hosted demo/pilot should answer cited queries in under 30s p95 | [ACCEPTANCE_TESTS.md](docs/ACCEPTANCE_TESTS.md) |
| Inference | `dev-ollama` for dev; hosted profiles for demos and pilots | [INFERENCE_PROFILES.md](docs/INFERENCE_PROFILES.md) |
| Product posture | Search-first with citations; synthesis is secondary | [DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md) |
| Data plane | Manual upload and prepared docs in v0 | [CUSTOMER_ONBOARDING.md](docs/CUSTOMER_ONBOARDING.md) |
| Control plane | Kotaemon users plus pilot access controls in v0 | [PILOT_DEPLOYMENT.md](docs/PILOT_DEPLOYMENT.md) |
| Tenancy | One customer per VPS for first pilots | [PILOT_DEPLOYMENT.md](docs/PILOT_DEPLOYMENT.md) |
| Platform | Kotaemon remains the engine; this repo stays a wrapper | [LICENSE_NOTES.md](LICENSE_NOTES.md) |

Later enterprise architecture docs are defined in the PDR and should be added in
their own steps: [PRODUCT_ARCHITECTURE.md](docs/PRODUCT_ARCHITECTURE.md),
[DATA_PLANE.md](docs/DATA_PLANE.md),
[CONTROL_PLANE.md](docs/CONTROL_PLANE.md), [TENANCY.md](docs/TENANCY.md), and
[PLATFORM.md](docs/PLATFORM.md).

## Quick Start

### Dev Path: `dev-ollama`

Use this for local development, offline testing, and private rehearsal.

```bash
./scripts/setup_ollama.sh
./scripts/preflight.sh
docker compose up -d
```

Open:

```text
http://localhost:7860
```

Then apply `config/inference/dev-ollama.example.yml` in Kotaemon Resources and
upload `sample-data/support/*`.

Full guide: [LOCAL_SETUP.md](docs/LOCAL_SETUP.md)

### Prospect Demo Path: `demo-hosted`

Use this for external demos. Ollama is dev-only; paid demos and pilots default
to hosted or customer-approved inference.

1. Set `OPENAI_API_KEY` or Azure credentials per
   [demo-hosted.example.yml](config/inference/demo-hosted.example.yml).
2. Apply the profile in Kotaemon Resources using
   [INFERENCE_PROFILES.md](docs/INFERENCE_PROFILES.md).
3. Pre-index `sample-data/support/*`.
4. Apply [support_v1.md](prompt-packs/support_v1.md).
5. Run the search-first flow in [DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md).
6. When the SLA script is added in the later benchmark step, run it before
   external demos:

```bash
INFERENCE_PROFILE=demo-hosted ./scripts/benchmark_query_sla.sh
```

Until then, manually time the standard demo questions.

## Inference Profiles

Profile files live in [config/inference/](config/inference/).

| Profile | Use | Default stance |
|---|---|---|
| `dev-ollama` | Local development and private rehearsal | Free/local, best-effort latency |
| `demo-hosted` | Prospect demos | Default external-demo path |
| `pilot-hosted` | First paid pilots | Default paid-pilot path |
| `pilot-private-gpu` | Customer forbids hosted inference | Exception path; must meet the same speed bar |

Read [INFERENCE_PROFILES.md](docs/INFERENCE_PROFILES.md) before switching
profiles. Re-index documents when changing embedding models.

## Commands

Make targets:

```bash
make help
make ollama
make smoke
make preflight
make up
make logs
make down
make reset-data
```

Direct scripts:

```bash
./scripts/setup_ollama.sh
./scripts/smoke_test_ollama.sh
./scripts/preflight.sh
./scripts/reset_local_data.sh
python scripts/prepare_docs.py --input raw_docs --output prepared_docs
```

## Search-First Demo Flow

Use [DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md). Lead with source lookup questions,
show citations and source preview, then ask policy questions. Do not spend the
demo waiting on upload or indexing; pre-index the collection before the call.

Suggested demo corpus: [sample-data/support/](sample-data/support/)

## Prompt Packs

Prompt packs live in [prompt-packs/](prompt-packs/):

- [support_v1.md](prompt-packs/support_v1.md) - support answers, customer-ready
  replies, citations, confidence, escalation, and tags.
- [ops_v1.md](prompt-packs/ops_v1.md) - operations workflows.
- [msp_it_v1.md](prompt-packs/msp_it_v1.md) - MSP and IT service workflows.
- [rfp_sales_v1.md](prompt-packs/rfp_sales_v1.md) - sales and RFP responses.

## Customer Pilot Flow

Start with approved docs only. Do not request full workspace exports, Slack DMs,
private channels, secrets, HR/legal folders, or random drive dumps.

1. Use [CUSTOMER_ONBOARDING.md](docs/CUSTOMER_ONBOARDING.md).
2. Apply [SOURCE_QUALITY_CHECKLIST.md](docs/SOURCE_QUALITY_CHECKLIST.md).
3. Prepare docs with `scripts/prepare_docs.py` when conversion helps.
4. Validate locally or privately with the customer sponsor.
5. For the first real pilot, deploy one dedicated VPS per customer.
6. Use `pilot-hosted` unless the customer requires a private GPU path.

Pilot guides:

- [PILOT_PLAYBOOK.md](docs/PILOT_PLAYBOOK.md)
- [PILOT_DEPLOYMENT.md](docs/PILOT_DEPLOYMENT.md)
- [DATA_HANDLING.md](docs/DATA_HANDLING.md)

Positioning line:

> We deploy a private AI answer bot from the docs your team already trusts. No
> full workspace integration required.

## Phase 2 Roadmap

Phase 2 should add enterprise capabilities only after the v0 pilot proves value:

- Data plane: connector contracts for Drive, Confluence, SharePoint, Slack
  exports, Jira, and Zendesk.
- Control plane: SSO/SAML, document ACLs, audit log fields, and policy controls.
- Tenancy: keep one VPS per customer first; consider multi-tenant SaaS later.
- Platform: wrap or migrate Kotaemon only when the v0 engine no longer meets
  product requirements.

Planned docs for those steps: [DATA_PLANE.md](docs/DATA_PLANE.md),
[CONTROL_PLANE.md](docs/CONTROL_PLANE.md), [TENANCY.md](docs/TENANCY.md), and
[PLATFORM.md](docs/PLATFORM.md).

## Troubleshooting And License Notes

- Troubleshooting: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- Kotaemon model setup: [KOTAEMON_MODEL_SETUP.md](docs/KOTAEMON_MODEL_SETUP.md)
- Acceptance tests: [ACCEPTANCE_TESTS.md](docs/ACCEPTANCE_TESTS.md)
- License and OSS notes: [LICENSE_NOTES.md](LICENSE_NOTES.md)

Preserve upstream license notices and do not represent Kotaemon code as custom
IP. Get legal review before commercial distribution or a deep fork.
