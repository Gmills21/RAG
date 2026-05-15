# Support Knowledge Bot MVP

A local-first, document-based knowledge assistant for support, customer success, and operations teams.

## 📋 Project Status

**Current Phase:** Steps 1-2 Complete (Infrastructure Setup)

| Phase | Status | Description |
|-------|--------|-------------|
| Steps 1-2 | ✅ **COMPLETE** | Repo structure + Docker Compose configured |
| Steps 3-6 | ⏳ **NEXT** | Ollama setup, preflight checks, Make targets |
| Steps 7-16 | ⬜ Pending | Sample data, prompts, documentation |
| Steps 17-21 | ⬜ Pending | Helper scripts, guides, playbooks |
| Steps 22-23 | ⬜ Pending | README polish + end-to-end validation |

**What's Ready Now:**
- ✅ Docker Compose configuration (local + pilot deployment modes)
- ✅ Repository structure and file organization
- ✅ Caddyfile for secure VPS deployments
- ✅ Documentation structure (placeholders in place)

**Not Yet Functional:**
- ⏳ Scripts are placeholders (setup, preflight, etc.)
- ⏳ Sample data files are placeholders
- ⏳ Prompt packs are placeholders
- ⏳ Documentation content is incomplete

---

## 🎯 What This Is

This is a **wrapper and packaging repository** for a local-first SMB support knowledge bot MVP.

**We did not build the RAG engine.** This MVP uses:

- **Kotaemon** — for document QA, citations, and source preview
- **Ollama** — for local LLM (qwen3:4b) and embeddings (nomic-embed-text)

This repo provides:
- Docker-based setup
- Ollama model scripts
- Prompt packs for support teams
- Sample data for demos
- Customer onboarding guides

## What This Is Not

This is **not**:
- A custom RAG system
- A custom vector database
- A custom chat UI
- A SaaS platform
- An integration marketplace

## 🚀 Quick Start (When Complete)

> **⚠️ Note:** Setup scripts are not yet implemented. These commands will work after Step 3-6 are complete.

```bash
# 1. Setup Ollama models (Step 3)
./scripts/setup_ollama.sh

# 2. Run preflight checks (Step 5)
./scripts/preflight.sh

# 3. Start Kotaemon
docker compose up -d

# 4. Open the app
open http://localhost:7860
```

For detailed setup instructions, see `docs/LOCAL_SETUP.md` (will be populated in Step 10).

---

## 🏗️ Architecture

### Local Development Mode (Current)

### Local Development Mode (Current)

```
┌─────────────────────────────────────────────┐
│  Developer Machine (localhost)              │
│                                             │
│  ┌──────────────┐      ┌─────────────────┐ │
│  │   Ollama     │◄─────│   Kotaemon      │ │
│  │ (port 11434) │      │  (port 7860)    │ │
│  │              │      │   [Docker]      │ │
│  │ • qwen3:4b   │      │                 │ │
│  │ • nomic-text │      │ • Web UI        │ │
│  └──────────────┘      │ • RAG engine    │ │
│                        │ • Citations     │ │
│  Local models          └─────────────────┘ │
│  running on host       Access via          │
│                        http://127.0.0.1:7860│
└─────────────────────────────────────────────┘
```

**Key Points:**
- Kotaemon runs in Docker, binds to localhost only
- Ollama runs on host machine (not containerized)
- Connection: `http://host.docker.internal:11434/v1/`
- No external access, no VPS/VPN/domains required
- Data persists in `./ktem_app_data/`

### Pilot Deployment Mode (VPS)

```
┌──────────────────────────────────────────────────┐
│  Single-Customer VPS (dedicated)                 │
│                                                  │
│  Internet ──► ┌───────────┐                     │
│   (HTTPS)     │   Caddy   │ (reverse proxy)     │
│               │  :80/:443 │                     │
│               └─────┬─────┘                     │
│                     │ private network           │
│                     ▼                           │
│        ┌────────────────────────┐               │
│        │      Kotaemon          │               │
│        │  (localhost:7860)      │               │
│        │   [Docker]             │               │
│        └────────┬───────────────┘               │
│                 │                               │
│                 ▼                               │
│        ┌──────────────┐                         │
│        │   Ollama     │                         │
│        │ (port 11434) │                         │
│        │ on same VPS  │                         │
│        └──────────────┘                         │
└──────────────────────────────────────────────────┘
```

**Key Points:**
- Raw port 7860 NOT exposed publicly (localhost only)
- Access ONLY through Caddy reverse proxy (HTTPS)
- Automatic Let's Encrypt certificates
- Optional basic authentication
- One VPS per customer for first pilots
- Customer-specific data folders

---

## 🗂️ Repository Structure

```
support-knowledge-bot/
├── 📄 README.md                     ← You are here (main control panel)
├── 📄 COMMANDER.md                  ← Step-by-step progress tracker
├── 📄 LICENSE_NOTES.md              ← OSS attribution
│
├── 🐳 Docker & Deployment
│   ├── docker-compose.yml           ← Local development (✅ ready)
│   ├── docker-compose.pilot.yml     ← VPS pilot override (✅ ready)
│   ├── Caddyfile.example            ← Reverse proxy config (✅ ready)
│   ├── .env.example                 ← Local env vars (placeholder)
│   └── .env.pilot.example           ← Pilot env vars (✅ ready)
│
├── 📜 scripts/                      ← Helper scripts (⏳ placeholders)
│   ├── setup_ollama.sh              ← Step 3: Pull local models
│   ├── smoke_test_ollama.sh         ← Step 4: Test Ollama APIs
│   ├── preflight.sh                 ← Step 5: Pre-launch checks
│   ├── prepare_docs.py              ← Step 17: Doc preprocessing
│   └── reset_local_data.sh          ← Step 18: Safe data reset
│
├── 🎯 prompt-packs/                 ← Domain-specific prompts (⏳ placeholders)
│   ├── support_v1.md                ← Step 8: Support team prompt
│   ├── ops_v1.md                    ← Step 9: Operations prompt
│   ├── msp_it_v1.md                 ← Step 9: MSP/IT prompt
│   └── rfp_sales_v1.md              ← Step 9: RFP/Sales prompt
│
├── 📊 sample-data/                  ← Demo corpus (⏳ placeholders)
│   └── support/                     ← Step 7: Fake support docs
│       ├── 01_refund_policy.md
│       ├── 02_sso_escalation_sop.md
│       ├── 03_billing_macros.csv
│       ├── 04_release_notes.md
│       ├── 05_solved_tickets.csv
│       └── 06_support_onboarding.md
│
├── 📚 docs/                         ← Guides and playbooks (⏳ placeholders)
│   ├── LOCAL_SETUP.md               ← Step 10: Dev environment setup
│   ├── KOTAEMON_MODEL_SETUP.md      ← Step 11: Model configuration
│   ├── CUSTOMER_ONBOARDING.md       ← Step 12: Pilot customer guide
│   ├── SOURCE_QUALITY_CHECKLIST.md  ← Step 13: Document curation
│   ├── DEMO_SCRIPT.md               ← Step 14: Sales demo flow
│   ├── ACCEPTANCE_TESTS.md          ← Step 15: QA checklist
│   ├── TROUBLESHOOTING.md           ← Step 19: Common issues
│   ├── PILOT_PLAYBOOK.md            ← Step 20: First customer workflow
│   ├── PILOT_DEPLOYMENT.md          ← Step 20: VPS deployment guide
│   └── DATA_HANDLING.md             ← Step 21: Data safety practices
│
├── 🧪 evals/                        ← Quality checks (⏳ placeholders)
│   ├── support_eval_questions.jsonl ← Step 16: Test question set
│   └── manual_eval_sheet.md         ← Step 16: Manual QA template
│
├── 📂 Overview/                     ← Project planning docs
│   ├── finalized_local_first_support_kb_pdr.md  ← The PDR (all 23 steps)
│   └── prompts.md                   ← Commander prompts (use with PDR)
│
├── ⚙️ .cursor/                      ← Cursor AI configuration
│   ├── rules/mvp-commander.mdc      ← One-step-at-a-time enforcement
│   └── agents/verifier.md           ← Step verification subagent
│
└── 🛠️ Makefile                      ← Step 6: Command shortcuts (placeholder)
```

---

## 🧰 Technology Stack

**Core Components:**
- **Base App:** Kotaemon (OSS document QA with citations)
- **LLM:** Ollama with qwen3:4b (local, 4B parameters)
- **Fallback LLM:** qwen3:1.7b (for low-resource environments)
- **Embeddings:** Ollama with nomic-embed-text (local)
- **Container:** Docker + Docker Compose
- **Reverse Proxy:** Caddy (for VPS pilots)
- **Deployment:** Local-first, with optional single-customer VPS

**Why These Choices:**
- ✅ No paid API keys required (fully local by default)
- ✅ Privacy-first (data never leaves your infrastructure)
- ✅ Simple deployment (Docker-based, portable)
- ✅ Production-ready citations (built into Kotaemon)
- ✅ Proven OSS stack (Kotaemon + Ollama well-tested)

---

## 📖 Documentation

### For Developers (Setting Up)
- [ ] `docs/LOCAL_SETUP.md` - Step-by-step local environment setup (Step 10)
- [ ] `docs/KOTAEMON_MODEL_SETUP.md` - Configure Ollama in Kotaemon UI (Step 11)
- [ ] `docs/TROUBLESHOOTING.md` - Common issues and fixes (Step 19)

### For Product/Sales (Demos & Pilots)
- [ ] `docs/DEMO_SCRIPT.md` - Sales demo walkthrough (Step 14)
- [ ] `docs/CUSTOMER_ONBOARDING.md` - Pilot customer guide (Step 12)
- [ ] `docs/SOURCE_QUALITY_CHECKLIST.md` - Document curation best practices (Step 13)
- [ ] `docs/PILOT_PLAYBOOK.md` - First customer workflow (Step 20)
- [ ] `docs/PILOT_DEPLOYMENT.md` - VPS deployment instructions (Step 20)

### For Quality Assurance
- [ ] `docs/ACCEPTANCE_TESTS.md` - Full QA checklist (Step 15)
- [ ] `evals/support_eval_questions.jsonl` - Test question set (Step 16)
- [ ] `evals/manual_eval_sheet.md` - Manual QA template (Step 16)

### For Operations
- [ ] `docs/DATA_HANDLING.md` - Data safety and privacy practices (Step 21)

*Note: Checkboxes indicate completion status. Empty = placeholder.*

---

## 🎭 What We Are Building

**In Scope (v0):**
- ✅ Docker-based Kotaemon wrapper
- ✅ Local Ollama model setup
- ✅ Prompt packs for support/ops/MSP use cases
- ✅ Sample data for demos
- ✅ Customer onboarding workflow
- ✅ Single-customer VPS deployment path
- ✅ Security-hardened pilot configuration

**Explicitly Out of Scope (v0):**
- ❌ Custom RAG backend
- ❌ Custom vector database
- ❌ Custom chat UI
- ❌ Slack/Google Drive/Jira API integrations
- ❌ Multi-tenant SaaS platform
- ❌ SSO/SAML authentication
- ❌ Usage analytics dashboard
- ❌ Fine-tuning pipelines

**Philosophy:** Package existing OSS (Kotaemon + Ollama) with great docs, prompts, and deployment workflows. Don't reinvent the wheel.

---

## 🧰 Technology Stack

**Core Components:**
- **Base App:** Kotaemon (OSS document QA with citations)  
- **LLM:** Ollama with qwen3:4b (local, 4B parameters)  
- **Fallback LLM:** qwen3:1.7b (for low-resource environments)  
- **Embeddings:** Ollama with nomic-embed-text (local)  
- **Container:** Docker + Docker Compose  
- **Reverse Proxy:** Caddy (for VPS pilots)  
- **Deployment:** Local-first, with optional single-customer VPS  

**Why These Choices:**
- ✅ No paid API keys required (fully local by default)
- ✅ Privacy-first (data never leaves your infrastructure)
- ✅ Simple deployment (Docker-based, portable)
- ✅ Production-ready citations (built into Kotaemon)
- ✅ Proven OSS stack (Kotaemon + Ollama well-tested)

---

## 📖 Documentation

### For Developers (Setting Up)
- [ ] `docs/LOCAL_SETUP.md` - Step-by-step local environment setup (Step 10)
- [ ] `docs/KOTAEMON_MODEL_SETUP.md` - Configure Ollama in Kotaemon UI (Step 11)
- [ ] `docs/TROUBLESHOOTING.md` - Common issues and fixes (Step 19)

### For Product/Sales (Demos & Pilots)
- [ ] `docs/DEMO_SCRIPT.md` - Sales demo walkthrough (Step 14)
- [ ] `docs/CUSTOMER_ONBOARDING.md` - Pilot customer guide (Step 12)
- [ ] `docs/SOURCE_QUALITY_CHECKLIST.md` - Document curation best practices (Step 13)
- [ ] `docs/PILOT_PLAYBOOK.md` - First customer workflow (Step 20)
- [ ] `docs/PILOT_DEPLOYMENT.md` - VPS deployment instructions (Step 20)

### For Quality Assurance
- [ ] `docs/ACCEPTANCE_TESTS.md` - Full QA checklist (Step 15)
- [ ] `evals/support_eval_questions.jsonl` - Test question set (Step 16)
- [ ] `evals/manual_eval_sheet.md` - Manual QA template (Step 16)

### For Operations
- [ ] `docs/DATA_HANDLING.md` - Data safety and privacy practices (Step 21)

*Note: Checkboxes indicate completion status. Empty = placeholder content from earlier steps.*

---

## 🎭 What We Are Building

**In Scope (v0):**
- ✅ Docker-based Kotaemon wrapper
- ✅ Local Ollama model setup
- ✅ Prompt packs for support/ops/MSP use cases
- ✅ Sample data for demos
- ✅ Customer onboarding workflow
- ✅ Single-customer VPS deployment path
- ✅ Security-hardened pilot configuration

**Explicitly Out of Scope (v0):**
- ❌ Custom RAG backend
- ❌ Custom vector database
- ❌ Custom chat UI
- ❌ Slack/Google Drive/Jira API integrations
- ❌ Multi-tenant SaaS platform
- ❌ SSO/SAML authentication
- ❌ Usage analytics dashboard
- ❌ Fine-tuning pipelines

**Philosophy:** Package existing OSS (Kotaemon + Ollama) with great docs, prompts, and deployment workflows. Don't reinvent the wheel.

---

## 🚦 Getting Started (Current State)

### ✅ What Works Now (Steps 1-2 Complete)

```bash
# Test Docker Compose configuration
docker compose config

# Test pilot deployment configuration
docker compose -f docker-compose.yml -f docker-compose.pilot.yml config
```

### ⏳ What's Next (Steps 3-6)

1. **Step 3:** Implement `scripts/setup_ollama.sh` to pull local models
2. **Step 4:** Implement `scripts/smoke_test_ollama.sh` to verify Ollama APIs
3. **Step 5:** Implement `scripts/preflight.sh` for pre-launch checks
4. **Step 6:** Implement Makefile shortcuts for common commands

### 📋 Following Along

Track progress in `COMMANDER.md` which shows completion status for all 23 PDR steps.

The project uses a strict one-step-at-a-time development workflow enforced by `.cursor/rules/mvp-commander.mdc`.

---

## 🤝 Contributing

This project follows the PDR (Product Design Requirements) in `Overview/finalized_local_first_support_kb_pdr.md`.

**Development Workflow:**
1. Each PDR step must pass acceptance criteria before moving forward
2. Read `Overview/finalized_local_first_support_kb_pdr.md` for the step requirements
3. Use prompts from `Overview/prompts.md` to guide implementation
4. Use Plan Mode before implementing each step
5. Run verifier subagent after implementation
6. Commit only after PASS status
7. See `COMMANDER.md` for detailed workflow

**Note:** The PDR and prompts files work together as a pair - agents should reference both.

**Key Principles:**
- Prefer existing OSS over custom code
- Keep local-first operation working
- No paid API dependencies in default path
- One step at a time, no exceptions

---

## License

See `LICENSE_NOTES.md` for OSS attribution and licensing details.
