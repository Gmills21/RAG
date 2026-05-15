# Acceptance Tests

Run this checklist before every internal demo, prospect demo, or customer
validation session. The key rule: `dev-ollama` is personal testing only;
customer-facing demos and paid pilots use `demo-hosted` or `pilot-hosted`.

## 1. Environment Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Required tools installed | Run `docker --version` and `docker compose version`. | Each command prints a version. |
| [ ] | Repo structure present | Run `ls docs scripts prompt-packs sample-data/support`. | All directories exist. |
| [ ] | No customer data in demo corpus | Inspect `sample-data/support/`. | Files are fake sample data only. |

## 2. Profile Selection Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Personal testing profile clear | Review `docs/INFERENCE_PROFILES.md`. | `dev-ollama` is marked personal/local only. |
| [ ] | Prospect demo profile clear | Review `docs/DEMO_SCRIPT.md`. | Prospect demos use `demo-hosted`. |
| [ ] | Paid pilot profile clear | Review `docs/PILOT_DEPLOYMENT.md`. | Paid pilots default to `pilot-hosted`. |
| [ ] | Private GPU exception clear | Review `docs/KOTAEMON_MODEL_SETUP.md`. | Private GPU is only for customers that forbid hosted inference. |

## 3. Ollama Checks For Personal Testing

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Ollama reachable | Run `curl http://localhost:11434/api/tags`. | JSON response is returned. |
| [ ] | Required local models installed | Run `ollama list`. | `qwen3:4b`, `qwen3:1.7b`, and `nomic-embed-text` appear. |
| [ ] | Local chat smoke test | Run `./scripts/smoke_test_ollama.sh`. | Script returns a local model response. |
| [ ] | Local-only warning understood | Review `docs/LOCAL_SETUP.md`. | Local Ollama is not presented as production speed. |

## 4. Docker/Kotaemon Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Compose validates | Run `docker compose config`. | Command exits 0. |
| [ ] | App starts | Run `docker compose up -d`. | `kotaemon` container starts. |
| [ ] | App reachable | Open `http://localhost:7860`. | Kotaemon UI loads. |
| [ ] | Raw port local only | Inspect `docker-compose.yml`. | Port is bound to `127.0.0.1:7860` by default. |

## 5. Model Configuration Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Dev resource configured | For personal testing, apply `config/inference/dev-ollama.example.yml`. | Resources save successfully. |
| [ ] | Demo resource configured | For prospect demos, apply `config/inference/demo-hosted.example.yml`. | Resources save successfully with hosted credentials. |
| [ ] | Pilot resource configured | For paid pilots, apply `config/inference/pilot-hosted.example.yml` or approved equivalent. | Resources save successfully with customer-approved endpoint. |
| [ ] | Re-index after embedding change | Re-upload or re-index after switching embedding profiles. | Sources are searchable with the new embedding model. |
| [ ] | New conversation after model change | Start a new chat after changing resources. | New chat uses current resources. |

## 6. Document Upload Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Sample collection created | Create `support-demo` collection. | Collection appears in Kotaemon. |
| [ ] | Sample docs uploaded | Upload all files from `sample-data/support/`. | All files appear in collection. |
| [ ] | Indexing complete | Wait until processing indicators finish. | Docs are searchable. |

## 7. Retrieval/Citation Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Refund retrieval | Ask: `Can we refund a customer after 20 days?` | Cites `01_refund_policy.md`. |
| [ ] | SSO retrieval | Ask: `What should I do if a customer has an SSO group sync issue?` | Cites `02_sso_escalation_sop.md`. |
| [ ] | Release retrieval | Ask: `What changed in the latest SSO release?` | Cites `04_release_notes.md`. |
| [ ] | Source preview | Open a cited source from an answer. | The source text supports the answer. |

## 8. Support Prompt Output Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Prompt pack applied | Paste `prompt-packs/support_v1.md` into Kotaemon prompt settings. | Answers follow the required format. |
| [ ] | Internal answer present | Ask an answerable support question. | Response includes `Internal answer`. |
| [ ] | Customer-ready reply present | Ask for a customer reply for failed invoice payment. | Response includes usable customer-facing wording. |
| [ ] | Escalation guidance present | Ask about annual enterprise refunds. | Response includes Finance Director/CSM escalation. |
| [ ] | Suggested tag present | Ask about refund request tagging. | Response suggests relevant support tags or asks for scenario detail. |

## 9. Refusal Behavior Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Unsupported question refused | Ask: `Is there a Berlin office lunch policy?` | Response says `Not enough source support`. |
| [ ] | Missing policy refused | Ask about usage-overage refunds. | Response says `Not enough source support`. |
| [ ] | No general-knowledge answer | Ask a company-specific question not in docs. | Bot does not invent policy. |

## 10. Performance Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Local response acceptable for dev | Ask one narrow question on `dev-ollama`. | Response completes, but no production claim is made. |
| [ ] | Hosted demo feels responsive | Time the seven demo questions on `demo-hosted`. | No obvious live-demo stalls; target is < 30s p95. |
| [ ] | Pilot profile feels responsive | Time the 20 known questions on `pilot-hosted` or approved equivalent. | Latency is documented before launch. |
| [ ] | Pre-indexing confirmed | Run demos only after upload/indexing is complete. | Demo does not wait on live upload. |

## 11. Pilot Readiness Checks

| Pass | Test | Steps | Expected result |
|---|---|---|---|
| [ ] | Customer docs curated | Use `docs/SOURCE_QUALITY_CHECKLIST.md`. | Only approved docs are selected. |
| [ ] | Customer onboarding complete | Use `docs/CUSTOMER_ONBOARDING.md`. | Customer understands no full workspace access is needed. |
| [ ] | Data handling reviewed | Use `docs/DATA_HANDLING.md`. | Customer understands approved docs and hosted inference data flow. |
| [ ] | Access control enabled | Use `Caddyfile.example` and `.env.pilot.example`. | Customer URL requires auth before users are invited. |
| [ ] | Pilot scope agreed | Use `docs/PILOT_PLAYBOOK.md`. | Scope is one team, 5 to 25 users, approved docs plus optional CSV exports. |
| [ ] | Deployment path chosen | Use `docs/PILOT_DEPLOYMENT.md`. | First real pilot uses a dedicated VPS plus `pilot-hosted` unless private GPU is required. |

## Manual Eval

After the checklist passes, run the questions in
`evals/support_eval_questions.jsonl` and record results in
`evals/manual_eval_sheet.md`.
