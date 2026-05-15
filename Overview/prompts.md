# MVP Commander — Prompt pack

This document is the **commander framework** for taking an agent through the Local RAG MVP PDR **one step at a time**. Use **Plan Mode** before implementation, **Project Rules** / `AGENTS.md` for persistent guardrails, and a **verifier subagent** for independent checks (per Cursor docs on rules, Plan Mode, and subagents).

**Operating principle:** one PDR step → plan → implement → verify → manual check → commit → next step. Do **not** tell Cursor to build the whole PDR at once; that leads to wandering, overbuilding, and skipped checks.

**Gates for every PDR step (order):**

1. PLAN  
2. **CLARIFY IF NEEDED** (new — see Gate 1.5 below)  
3. APPROVE  
4. IMPLEMENT  
5. VERIFY  
6. FIX IF NEEDED  
7. MANUAL CHECK  
8. COMMIT  
9. NEXT STEP  

**Rule:** Cursor is not allowed to move to the next PDR step until the current step passes.

**Clarification rule (applies to every prompt below):** If, while reading the prompt or executing it, Cursor identifies an essential detail that is missing, ambiguous, contradicted by repo state, or has multiple reasonable interpretations that would lead to materially different implementations, Cursor MUST stop and ask using the format defined in `.cursor/rules/mvp-commander.mdc` "Clarification gate" section. Guessing on essentials is a defect, not a feature. Asking is required.

**Stack reminder (paste or keep in rules):** Do not build custom RAG. Do not invent a product. Wire together Kotaemon + Ollama + docs + scripts.

---

## Prompt groups (how this file is organized)

| Group | Name | Prompt numbers | When you use it |
|-------|------|----------------|-----------------|
| **Group 1** | **Step 0 prompt** | **1** | **Once** before PDR Step 1 — creates commander guardrails only. |
| **Group 2** | **Standard prompts** | **2 → 7** (plus **2.5** when needed) | **Every** PDR Step **1–23**, in order. **Prompt 2.5** only if **Prompt 2** raised open questions (clarification gate). **Prompt 5** only if **Prompt 4** (verifier) returns **FAIL**; then re-run **Prompt 4** until PASS. **GATE 3** (implement) and **GATE 8** (next step) are not separate pastes. |
| **Group 3** | **Review prompts** (optional) | **8, 9, 10** | When you need **recovery or audit**, not on every step: **8** — scope / overbuild; **9** — paid API drift after touching models, env, Docker, config, or docs; **10** — citation / grounding once the app runs. |
| **Group 4** | **PDR Step 23 / MVP completion prompt** | **11** | **Once** after **PDR Step 23** passes — skeptical “is this demoable?” review. |

**Important:** **Prompt 5** (verifier fix) lives in **Group 2**, not Group 3. It is the **required** path when verify fails, not an optional review.

---

## Prompt index (how many prompts per commander step)

| Group / when | Prompt numbers you use (in order) | How many prompts |
|----------------|-----------------------------------|------------------|
| **Group 1 — Step 0** | Prompt 1 only | **1** |
| **Group 2 — each PDR Step 1–23** (happy path, no open questions) | Prompt 2 → Prompt 3 → Prompt 4 → Prompt 6 → Prompt 7 | **5** |
| **Group 2 — each PDR Step 1–23** (with open questions raised in PLAN) | Prompt 2 → **Prompt 2.5** → Prompt 3 → Prompt 4 → Prompt 6 → Prompt 7 | **6** |
| **Group 2 — each PDR Step 1–23** (if verify fails) | After Prompt 4 fails: **Prompt 5**, then **Prompt 4** again; repeat until PASS; then **Prompt 6 → Prompt 7** | **5 + 2n** paste prompts, where **n** = number of fail cycles *(each cycle is one Prompt 5 and one re-run of Prompt 4)* |
| **Group 3 — Review** (optional) | Prompt 8 — overbuild / re-scope | **0 or 1** per incident |
| **Group 3 — Review** (optional) | Prompt 9 — paid API audit | **0 or 1** |
| **Group 3 — Review** (optional) | Prompt 10 — citation / source preview | **0 or 1** when testing grounding |
| **Group 4 — after PDR Step 23 passes** | Prompt 11 — demo readiness | **1** |

**Unique paste prompts in this file:** **Prompt 1** through **Prompt 11**, plus **Prompt 2.5** (twelve definitions total). **Group 2** reuses Prompts **2–7** on every PDR step (and **2.5** whenever the PLAN raised open questions); **Group 1** uses Prompt **1** once.

**Gate mapping:** Prompt 2 = PLAN · **Prompt 2.5 = CLARIFY IF NEEDED** · Prompt 3 = APPROVE (+ kicks off IMPLEMENT) · Prompt 4 = VERIFY · Prompt 5 = FIX IF NEEDED · Prompt 6 = MANUAL CHECK · Prompt 7 = COMMIT · then NEXT STEP (no paste).

### Prompt catalog (all **12** paste prompts)

| Group | # | When to use |
|-------|---|-------------|
| **1 — Step 0** | **Prompt 1** | Once — create commander files |
| **2 — Standard** | **Prompt 2** | Every PDR step — plan (before code); MUST include Open Questions section |
| **2 — Standard** | **Prompt 2.5** | Only if Prompt 2 raised open questions — pass user answers back, agent updates plan |
| **2 — Standard** | **Prompt 3** | Every PDR step — approve + implement kickoff |
| **2 — Standard** | **Prompt 4** | Every PDR step — verify (often new chat + verifier subagent) |
| **2 — Standard** | **Prompt 5** | Only if Prompt 4 fails — minimal fix |
| **2 — Standard** | **Prompt 6** | Every PDR step — ten manual-check questions |
| **2 — Standard** | **Prompt 7** | Every PDR step — commit (after PASS) |
| **3 — Review** | **Prompt 8** | Optional — stop overbuilding / re-scope |
| **3 — Review** | **Prompt 9** | Optional — paid API audit |
| **3 — Review** | **Prompt 10** | Optional — citation / source preview workflow |
| **4 — Step 23 / completion** | **Prompt 11** | Once after PDR Step 23 passes — demo readiness |

---

## Group 1 — Step 0 prompt (before PDR Step 1)

Complete **Step 0** once, before any PDR implementation step. It creates the commander files only (no product features). **Uses Prompt 1** (count: **1**).

### Prompt 1 — Step 0: create commander files (GATE: PLAN + IMPLEMENT)

We are building the Local RAG MVP from @Overview/finalized_local_first_support_kb_pdr.md.

Before implementing the MVP, create the Cursor operating framework for this repo.

Create:

1. .cursor/rules/mvp-commander.mdc
2. .cursor/agents/verifier.md
3. COMMANDER.md

The goal is to force one-step-at-a-time development.

Rules:
- Do not implement any product feature yet.
- Do not create custom RAG logic.
- Do not add paid API dependencies.
- Do not proceed beyond creating these commander files.
- The MVP must use existing OSS as much as possible, mainly Kotaemon + Ollama.
- Every future implementation step must include acceptance checks.
- Every future implementation step must end with a PASS/FAIL report.

After creating the files, show me:
- files created
- contents summary
- how I should use them
- exact next prompt for PDR Step 1

### Reference templates for Prompt 1 (not separate prompts)

These are the target contents Cursor should produce when you run **Prompt 1**; wording inside the code blocks is unchanged from your commander spec.

#### Rule file — `.cursor/rules/mvp-commander.mdc` (have Cursor match closely)

```text
---
alwaysApply: true
---

# MVP Commander Rule

This repo builds a local-first RAG/document-QA MVP using existing open-source tools.

## Non-negotiables

- Use the PDR as the source of truth: `Overview/finalized_local_first_support_kb_pdr.md`.
- Implement exactly one PDR step at a time.
- Never move to the next step unless the user explicitly approves.
- Do not build a custom RAG system unless the PDR explicitly requires it.
- Prefer existing OSS capabilities from Kotaemon, Ollama, MarkItDown, Docker, and scripts.
- Do not add paid LLM API requirements for the default path.
- Default LLM must be Ollama-compatible.
- Default embedding model must be local/Ollama-compatible.
- Do not add Google Drive, Slack, Jira, Zendesk, or other API integrations in v0.
- Do not run destructive commands without explicit user approval.
- Do not delete files, reset git history, force-push, or wipe data without explicit approval.

## Required workflow for every PDR step

For each step:

1. Read the step from the PDR.
2. Restate the goal.
3. Produce a short implementation plan.
4. Wait for user approval before coding if the user asked for Plan Mode.
5. Implement only that step.
6. Run the step's acceptance checks.
7. Report:
   - files changed
   - commands run
   - test/check results
   - what passed
   - what failed
   - what was not done
   - risks or assumptions
8. Stop.

## Output format after every step

Return this exact report:

### Step Result

Status: PASS / FAIL / PARTIAL

PDR step:
...

Files changed:
...

Commands run:
...

Acceptance checks:
- [ ] ...
- [ ] ...

Evidence:
...

Manual check for user:
...

Known risks:
...

Recommended next prompt:
...
```

#### Verifier subagent — `.cursor/agents/verifier.md` (have Cursor match closely)

```text
---
name: verifier
description: Independently verifies one completed PDR step before the user moves on.
---

You are the MVP verifier.

Your job is not to build. Your job is to inspect, test, and challenge the implementation.

For the requested PDR step:

1. Read `Overview/finalized_local_first_support_kb_pdr.md`.
2. Identify the exact acceptance checks for the step.
3. Inspect the git diff.
4. Run relevant commands.
5. Check for overbuilding or scope creep.
6. Check that the implementation uses existing OSS rather than custom RAG logic.
7. Check that Ollama/local-model defaults are preserved.
8. Check that no paid API dependency was introduced.
9. Return PASS only if the step is actually complete.

Output:

Status: PASS / FAIL

Evidence:
...

Problems found:
...

Required fixes before next step:
...

Optional improvements, not blocking:
...
```

### Step 0 — MANUAL CHECK (no paste prompt)

Confirm the three files exist, summaries match intent, and you understand how Step 1's loop below will run.

### Step 0 — COMMIT (no paste prompt)

Only after the above passes: commit with a clear message (e.g. commander framework only).

### Step 0 — NEXT STEP (no paste prompt)

Proceed to **PDR Step 1** and run **Prompts 2–7** for that step.

---

## Group 2 — Standard prompts (every PDR Step 1–23)

Repeat for each PDR step: **5** prompts on the happy path; add **Prompt 5** + re-run **Prompt 4** per verify-fail cycle.

Replace `[X]` with the step number and `[STEP NAME]` with the step title from `Overview/finalized_local_first_support_kb_pdr.md`.

**Order per PDR step:** Prompt 2 → *(if open questions: Prompt 2.5)* → Prompt 3 → *(implement in same chat)* → Prompt 4 → *(if FAIL: Prompt 5, then Prompt 4 again)* → Prompt 6 → Prompt 7.

### Prompt 2 — GATE 1: PLAN (planning prompt)

We are on PDR Step [X]: [STEP NAME] from @Overview/finalized_local_first_support_kb_pdr.md.

Use Plan Mode first.

Your job:
- Read only this step and any directly relevant earlier context.
- Do not implement yet.
- Do not move to the next step.
- Do not add extra features.
- Do not build custom RAG.
- Prefer existing OSS and simple scripts.

Return:
1. The exact goal of this step.
2. Files you expect to create or edit.
3. Commands you expect to run.
4. Acceptance checks you will use.
5. Risks or assumptions.
6. **Open Questions for the user** — REQUIRED section. Apply the clarification gate from `.cursor/rules/mvp-commander.mdc`. List every essential detail that is missing, ambiguous, contradicted by repo state, or has multiple reasonable interpretations. If there are none, say "None — every required detail is unambiguous in the PDR and repo state" and briefly explain why. Use the CLARIFICATION REQUIRED block format from the rule file. Maximum three questions; if you have more, propose a re-scope instead.

Stop after the plan and wait for approval (or for clarification answers if you raised any open questions).

### Prompt 2.5 — GATE 1.5: CLARIFY IF NEEDED (only if Prompt 2 raised open questions)

Use only if Prompt 2 returned a non-empty "Open Questions" section. The user pastes back:

Answers to your open questions:

Q1: [answer — "A", "B", "you decide", or one short sentence]
Q2: [answer]
Q3: [answer]

Update your plan to reflect these answers. Do not implement yet. Re-emit just the changed sections of the plan (Files, Commands, Acceptance checks, Risks) so I can confirm the plan still makes sense before approving.

If any answer would push us outside PDR §1.3 / §2.2 scope, flag it and propose a smaller scope instead of building.

### Prompt 3 — GATE 2: APPROVE (+ kicks off GATE 3: IMPLEMENT)

Approved. Implement only PDR Step [X].

Rules:
- Do not move to Step [X+1].
- Do not add features outside this step.
- Run the acceptance checks from the PDR.
- If a command fails, stop and explain instead of guessing.
- **If during implementation you hit a NEW essential question that did not surface in the plan, stop and emit a CLARIFICATION REQUIRED block (format defined in `.cursor/rules/mvp-commander.mdc`). Do not commit speculative work. Revert any uncommitted speculative edits in the working tree first, then ask.**
- At the end, give the Step Result report required by .cursor/rules/mvp-commander.mdc. Include the "Clarifying questions asked this step" and "Assumptions made" sections — never leave them blank; if there were none, explicitly say so and explain why.

### GATE 3: IMPLEMENT (no separate paste prompt)

*(Agent implements after Prompt 3; same chat unless you intentionally split work.)*

### Prompt 4 — GATE 4: VERIFY (verifier prompt)

After Cursor says it is done, start a new Cursor chat if possible and paste:

Use the verifier subagent.

Verify PDR Step [X]: [STEP NAME].

Do not implement new features unless a fix is required and I explicitly approve it.

Tasks:
- Read @Overview/finalized_local_first_support_kb_pdr.md for Step [X].
- Inspect the current git diff.
- Run the relevant acceptance checks.
- Confirm the implementation stayed in scope.
- Confirm no paid LLM API dependency was introduced.
- Confirm no custom RAG system was built.
- Confirm the local Ollama-first path still works.

Return PASS or FAIL.

If FAIL, list the smallest required fixes.

### Prompt 5 — GATE 5: FIX IF NEEDED (only if Prompt 4 returns FAIL)

Fix only the verifier's blocking issues for PDR Step [X].

Do not refactor unrelated files.
Do not move to the next step.
Do not add optional improvements.
After fixing, rerun the failed checks and return the Step Result report again.

### Prompt 6 — GATE 6: MANUAL CHECK (ten questions)

Do not move on unless Cursor can answer these cleanly:

1. What exact files changed?
2. Why did each changed file need to change?
3. What commands did you run?
4. What was the output of the checks?
5. Which acceptance criteria passed?
6. Which acceptance criteria failed or were skipped?
7. Did you add any custom RAG code?
8. Did you add any paid API dependency?
9. Can this step be reproduced from a clean clone?
10. What should I manually click/test before moving on?

If the answer is vague, force it to rerun checks.

### Prompt 7 — GATE 7: COMMIT AND PUSH (only after PASS)

Create a git commit and push for PDR Step [X].

Before committing:
- Show git status.
- Show git diff --stat.
- Confirm no secrets or local data files are being committed.

Commit and push workflow:
1. Commit with message: `step [X]: [short description]`
2. Create feature branch: `cursor/step-[X]-[description]-6507`
3. Push to GitHub: `git push -u origin [branch-name]`
4. Create draft PR with detailed step description

This ensures:
- Each step is backed up to GitHub immediately
- Step-by-step recovery is possible
- Debugging can start from any specific step
- Multiple agents can access the same incremental progress

After pushing, show:
- Commit hash
- Branch name
- PR link
- Next recommended PDR step

### GATE 8: NEXT STEP (no paste prompt)

Increment `[X]` and repeat from **Prompt 2** for the next PDR step. Do not skip gates.

---

## Group 3 — Review prompts (optional)

Use **Group 3** when you need extra **scope control, dependency audit, or product-quality review** — not on every step. (If **Prompt 4** fails, use **Prompt 5** in **Group 2** first; that is the required fix loop, not optional.)

### Prompt 8 — “Do not overbuild” (re-scope)

Stop and re-scope.

You are overbuilding.

Return to the PDR principle:
- We are not building a custom RAG SaaS.
- We are packaging existing OSS.
- The default stack is Kotaemon + Ollama + local docs + prompt packs + setup docs.
- Do not add integrations, auth systems, billing, custom vector DB logic, custom chat UI, or cloud deployment unless the current PDR step explicitly requires it.

Now revise your plan to complete only PDR Step [X].

This will save you hours.

### Prompt 9 — “No paid API” audit (after steps touching models, env, config, Docker, or docs)

Audit the repo for paid API dependencies.

Check:
- .env.example
- docker-compose.yml
- scripts/
- docs/
- README
- any config files

Confirm:
1. The default LLM path uses Ollama.
2. The default embedding path uses Ollama/local embeddings.
3. No OpenAI, Anthropic, Cohere, or paid API key is required for local MVP startup.
4. If paid APIs are mentioned, they are clearly optional and not required.

Return PASS/FAIL with file references.

### Prompt 10 — Citation / source preview check (after the app runs)

Verify the cited-answer workflow.

Using the sample support docs:
1. Upload the sample docs into the app.
2. Ask 5 questions from docs/eval/support-eval-questions.md.
3. Confirm each useful answer includes source references.
4. Confirm the user can open or inspect the supporting document/source.
5. Confirm the answer does not invent information when the source does not contain it.
6. Record any failures in docs/eval/manual-test-results.md.

Do not change code unless I approve.
Return PASS/FAIL.

---

## Group 4 — PDR Step 23 / MVP completion prompt

Run **once** after **PDR Step 23** passes (full MVP run / end-to-end local test is green). This is the capstone “demo readiness” review, not part of the per-step loop.

### Prompt 11 — Final “is this demoable?” (when PDR Step 23 passes)

Act as a skeptical first customer.

Test this MVP as if you are Head of Support at a 100-person B2B SaaS company.

Evaluate:
1. Can I understand what this is in 60 seconds?
2. Can I run it locally without paid LLM costs?
3. Can I upload docs?
4. Can I ask questions?
5. Are answers cited?
6. Can I see where the answer came from?
7. Does the support prompt format produce customer-ready replies?
8. What would block me from using this in a real pilot?
9. What is the smallest fix for each blocker?

Return:
- Demo readiness score from 1-10
- Blocking issues
- Non-blocking issues
- Recommended fixes before prospect demo

Do not accept a demo readiness score below 8/10 unless you are only doing an internal test.

---

## Reference: PDR steps vs minimum bar (checklist, not paste prompts)

Use this table while stepping through the PDR; minimum checks are what verifier + you confirm before advancing.

| PDR step | What Cursor is allowed to do | Minimum check before moving on |
|----------|------------------------------|--------------------------------|
| Step 1: repo skeleton | Create folders, placeholder docs, basic structure | tree -a or equivalent shows expected folders; no product code invented |
| Step 2: Docker Compose for Kotaemon | Add compose file for Kotaemon | docker compose config passes; docker compose up -d starts; app reachable locally |
| Step 3: Ollama setup script | Add script to install/pull local models | ollama list shows selected chat + embedding models |
| Step 4: Ollama smoke test | Add script that calls Ollama locally | Script returns a real local model response |
| Step 5: preflight script | Check Docker, Ollama, ports, env | make preflight or script passes/fails clearly |
| Step 6: Makefile shortcuts | Add make up, make down, make test, etc. | Every Make target works or prints a useful error |
| Step 7: sample support data | Add fake support docs/tickets | Files exist, realistic enough for demo, no sensitive data |
| Step 8: support prompt pack | Add support answer templates | Template includes answer, customer reply, source, confidence, escalation |
| Step 9: ops/MSP/RFP prompt packs | Add other vertical templates | Each template is distinct, useful, and not generic fluff |
| Step 10: local setup docs | Write dev setup guide | A new user can follow it from clone to local app |
| Step 11: Kotaemon model setup docs | Explain Ollama config inside Kotaemon | Includes exact model names and local base URL guidance |
| Step 12: customer onboarding docs | Explain what files customer should upload | Clear upload list, exclusions, and source-quality expectations |
| Step 13: source quality checklist | Add checklist for trusted docs | Distinguishes trusted, stale, noisy, private, and excluded docs |
| Step 14: demo script | Add sales demo flow | Demo has exact questions and expected answer style |
| Step 15: acceptance tests doc | Add full test plan | Tests cover local model, upload, citation, source preview, output template |
| Step 16: eval question set | Add manual eval questions | Includes pass/fail criteria for answer quality |
| Step 17: doc prep script | Add optional preprocessing script | Runs on sample folder and outputs clean Markdown |
| Step 18: reset-local-data script | Add safe reset helper | Requires confirmation; does not delete repo or secrets |
| Step 19: troubleshooting guide | Add common failure fixes | Covers Docker, Ollama, model config, ports, file parsing |
| Step 20: pilot playbook | Add first-customer workflow | Includes paid pilot scope, setup steps, success metrics |
| Step 21: data handling guide | Add data safety guide | Explains local-only, no broad integrations, no secret uploads |
| Step 22: README control panel | Make README the main dashboard | README links to all commands/docs/scripts |
| Step 23: full MVP run | End-to-end local test | Fresh clone can run app, upload docs, ask questions, get cited answers |

**Note:** Kotaemon often runs as a Gradio app on port 7860 in Docker examples; have Cursor verify the actual port from your compose file instead of assuming.

---

## Good vs bad responses (quality bar for Step Result)

**Good commander response example:**

Status: PASS

Files changed:
- docker-compose.yml
- .env.example
- docs/local-setup.md

Commands run:
- docker compose config
- docker compose up -d
- docker compose ps
- docker compose down

Acceptance checks:
- [x] Docker Compose file validates
- [x] Kotaemon container starts
- [x] App reachable on localhost
- [x] Persistent volume configured

Manual check:
Open http://localhost:7860 and confirm the Kotaemon UI loads.

Known risks:
The first run may take several minutes because the Docker image must download.

**Bad response (do not accept):**

Everything should work now.

---

## Operating stack (reference)

- Cursor Plan Mode = before every step  
- Cursor Project Rule = always-on guardrails  
- Cursor Verifier Subagent = after every step  
- Git commit = only after PASS  
- g-stack = optional extra review layer later (see g-stack README; Cursor host `--host cursor`; skills under `~/.cursor/skills/gstack-*`)  

**Mantra:** Cursor builds one step. Verifier tries to break it. You manually check the product. Then you commit.
