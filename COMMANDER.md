# Commander Framework for Local RAG MVP

This document tracks the step-by-step implementation of the Local RAG MVP from the PDR.

## What This Is

The Commander framework enforces **one-step-at-a-time development** for the Local RAG MVP. It prevents scope creep, overbuilding, and skipped validation.

## Operating Files

1. **`.cursor/rules/mvp-commander.mdc`** — Always-on project rule that prevents moving ahead without approval
2. **`.cursor/agents/verifier.md`** — Independent verification subagent that checks each step
3. **`COMMANDER.md`** (this file) — Progress tracker and usage guide
4. **`Overview/finalized_local_first_support_kb_pdr.md`** — The PDR (Product Design Requirements) with all 23 steps
5. **`Overview/prompts.md`** — The prompt pack with all commander prompts (use with PDR)

## How to Use

### For Each PDR Step (1-23):

Run these prompts in order:

1. **Prompt 2** — PLAN: Read the step, create implementation plan
2. **Prompt 3** — APPROVE + IMPLEMENT: Approve plan and execute
3. **Prompt 4** — VERIFY: Use verifier subagent to check work
4. **Prompt 5** — FIX (only if verify fails): Minimal fix, then re-verify
5. **Prompt 6** — MANUAL CHECK: Answer 10 questions about the work
6. **Prompt 7** — COMMIT AND PUSH: Create commit, branch, push to GitHub, create draft PR

**Important:** Each step MUST be pushed to GitHub immediately after completion. This ensures:
- Step-by-step recovery if something breaks
- Multiple agents can see all progress
- Easy debugging by checking out specific step branches
- Incremental backup of all work

Then move to next step.

### Review Prompts (Optional):

- **Prompt 8** — Stop overbuilding / re-scope
- **Prompt 9** — Audit for paid API dependencies
- **Prompt 10** — Verify citation/source preview workflow

### Final Validation:

- **Prompt 11** — After Step 23: Full demo readiness check

## PDR Step Progress

| Step | Status | Description | Branch | PR |
|------|--------|-------------|--------|-----|
| 0 | ✅ COMPLETE | Commander framework setup | cursor/step-0-commander-framework-6507 | - |
| 1 | ✅ COMPLETE | Create wrapper repo skeleton | cursor/step-1-wrapper-skeleton-6507 | - |
| 2 | ✅ COMPLETE | Add Docker Compose for Kotaemon | cursor/step-2-docker-compose-6507 | #5 |
| 3 | ⬜ PENDING | Add Ollama setup script |
| 4 | ⬜ PENDING | Add Ollama smoke test script |
| 5 | ⬜ PENDING | Add preflight script |
| 6 | ⬜ PENDING | Add Makefile shortcuts |
| 7 | ⬜ PENDING | Add sample support data |
| 8 | ⬜ PENDING | Add support prompt pack |
| 9 | ⬜ PENDING | Add ops, MSP/IT, and RFP prompt packs |
| 10 | ⬜ PENDING | Add local setup docs |
| 11 | ⬜ PENDING | Add Kotaemon model setup docs |
| 12 | ⬜ PENDING | Add customer onboarding docs |
| 13 | ⬜ PENDING | Add source quality checklist |
| 14 | ⬜ PENDING | Add demo script |
| 15 | ⬜ PENDING | Add acceptance tests doc |
| 16 | ⬜ PENDING | Add eval question set |
| 17 | ⬜ PENDING | Add document preparation script |
| 18 | ⬜ PENDING | Add reset-local-data script |
| 19 | ⬜ PENDING | Add troubleshooting guide |
| 20 | ⬜ PENDING | Add pilot playbook |
| 21 | ⬜ PENDING | Add data handling guide |
| 22 | ⬜ PENDING | Update README as main control panel |
| 23 | ⬜ PENDING | Full MVP run acceptance |

## Key Principles

### What We ARE Building:
- A wrapper repo around Kotaemon + Ollama
- Docker-based setup
- Local-first development workflow
- Prompt packs for support use cases
- Sample data and demo scripts
- Customer onboarding guides

### What We ARE NOT Building:
- Custom RAG backend
- Custom vector database
- Custom chat UI
- Connector marketplace
- Self-serve SaaS app
- API integrations (Slack/Drive/Jira) in v0

## Stack

- **Base App:** Kotaemon (OSS document QA with citations)
- **LLM:** Ollama with qwen3:4b (local)
- **Embeddings:** Ollama with nomic-embed-text (local)
- **Container:** Docker
- **Deployment:** Local-first, with optional single-customer VPS for pilots

## Next Step

You have completed **Step 0** (Commander framework setup).

**Next:** Proceed to PDR Step 3 using Prompts 2-7 from `Overview/prompts.md` (if following the commander framework).

Read both `Overview/finalized_local_first_support_kb_pdr.md` (the what) and `Overview/prompts.md` (the how) together.

Start with:
```
We are on PDR Step 1: Create the wrapper repo skeleton from @Overview/finalized_local_first_support_kb_pdr.md.

Use Plan Mode first.
...
```

## Notes

- Always check acceptance criteria before marking a step complete
- Never skip the verifier step
- Commit only after PASS
- One step at a time, no exceptions
