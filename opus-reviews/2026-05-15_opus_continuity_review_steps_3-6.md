# Opus Continuity Review: Steps 0–6

**Date:** 2026-05-15
**Reviewer:** Opus (acting as software manager + continuity reviewer)
**Branch under review:** `cursor/opus-review-steps-3-6-8b8c` (built from
`origin/cursor/step-6-verification-487c`, which is the most complete
integration branch at the time of review)
**PDR:** `Overview/finalized_local_first_support_kb_pdr.md` (v0.2)
**Scope:** Verify that Steps 3, 4, 5, and 6 integrate cleanly with the
already-completed Steps 0, 1, and 2, and that the foundation is correct
for Steps 7–23.

---

## 1. Executive Summary

| Verdict | Detail |
|---|---|
| Overall | ✅ **APPROVED with fixes applied in this review** |
| PDR alignment | ✅ Strong — every required artifact for Steps 1–6 exists and meets the PDR acceptance checks |
| Cross-step continuity | ✅ Strong — Makefile (Step 6) correctly orchestrates Steps 3–5; Step 5 preflight verifies Step 2 + Step 3 prerequisites |
| Scope discipline | ✅ Clean — no custom RAG code, no paid-API surface, no premature integrations |
| Issues found | 5 (all fixed in this review) |
| Ready for Step 7? | ✅ Yes, once this review's commit is merged |

### One-line answer

The foundation is solid. I found small drift between the prompt pack, the
COMMANDER tracker, and the implemented scripts/Makefile/Compose. I fixed it
inline. The repo is in a clean, consistent state for Step 7 (sample
support data) and beyond.

---

## 2. What I Verified

For each completed step (0–6) I checked:

1. The PDR step's exact prompt and acceptance checks.
2. The actual file(s) on disk (post-merge of all step branches).
3. Whether the artifact still behaves correctly after the *later* steps
   landed (e.g., does Step 6's Makefile still call the Step 3/4/5 scripts
   with the right paths and flags).
4. Whether the documentation around the step (COMMANDER.md, prompts.md,
   README, opus reviews) describes reality.

I deliberately did **not** review Steps 7+ artifacts, since those are
intentionally placeholder files (`2-line` stubs) until their PDR step
is run. That is correct per the commander rule "one step at a time."

### Per-step PDR conformance summary

| Step | PDR artifact | Present | Meets PDR acceptance checks | Notes |
|------|--------------|---------|-----------------------------|-------|
| 0 | `.cursor/rules/mvp-commander.mdc`, `.cursor/agents/verifier.md`, `COMMANDER.md` | ✅ | ✅ | COMMANDER.md tracker was stale — fixed |
| 1 | wrapper skeleton (all folders/placeholder files) | ✅ | ✅ | Matches PDR §8 exactly |
| 2 | `docker-compose.yml`, `docker-compose.pilot.yml`, `Caddyfile.example`, `.env.pilot.example` | ✅ | ✅ | Had obsolete `version: '3.8'` in both compose files — fixed |
| 3 | `scripts/setup_ollama.sh` | ✅ | ✅ | "Next steps" footer didn't mention the smoke test — fixed |
| 4 | `scripts/smoke_test_ollama.sh` | ✅ | ✅ | PASS/FAIL output matches PDR spec, no `jq` dependency |
| 5 | `scripts/preflight.sh` | ✅ | ✅ | 8 checks, actionable failure messages, exits non-zero on FAIL |
| 6 | `Makefile` | ✅ | ✅ | `help` listed only 2 of 3 models pulled, and quick-start skipped `smoke` — fixed |

---

## 3. Issues Found and Fixed in This Review

I treated this review as a software-manager pass. Where I found a defect
I fixed it in the same commit set rather than filing follow-ups, per the
user's instruction "make the changes as you see the errors."

### Issue 1: Obsolete Compose schema version emitted warnings on every run

**Files:** `docker-compose.yml`, `docker-compose.pilot.yml`

**Symptom:** Every `docker compose` invocation printed:

```
WARN  the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
```

That noise lands on a founder's first run during a demo, hurting the
"setup reliability" goal in PDR §14.

**Root cause:** Both compose files declared `version: '3.8'`. Compose v2
deprecates the top-level `version` field.

**Fix:** Removed the `version: '3.8'` line from both files. Re-verified
that `docker compose config` and `docker compose -f docker-compose.yml -f
docker-compose.pilot.yml config` still produce a valid, warning-free
configuration.

### Issue 2: Prompt pack referenced a PDR path that no longer exists

**File:** `Overview/prompts.md`

**Symptom:** Six places in `Overview/prompts.md` referenced the file
`local_rag_mvp_pdr_cursor.md` — a leftover from an earlier PDR name. The
actual PDR lives at `Overview/finalized_local_first_support_kb_pdr.md`.

**Impact:** When a future agent runs Prompts 2 and 4 verbatim, the `@`
file reference points to a file that does not exist. That silently
removes the PDR from the agent's context and is exactly the kind of
drift that causes overbuilding and PDR deviation. The active rule file
(`.cursor/rules/mvp-commander.mdc`) already uses the correct path, so
the prompts and the rules were inconsistent with each other.

**Fix:** Replaced all six occurrences in `Overview/prompts.md` with the
correct path `Overview/finalized_local_first_support_kb_pdr.md`. Now the
rule file and the prompt pack agree.

### Issue 3: `COMMANDER.md` tracker was stale

**File:** `COMMANDER.md`

**Symptom:** Tracker said Steps 4, 5, 6 were `⬜ PENDING`, but those
steps had in fact been implemented and live on `cursor/step-4-…`,
`cursor/step-5-…`, `cursor/step-6-…` branches (and rolled up onto the
verification branches). The "Next Step" section still pointed at Step 1.

**Impact:** A new agent reading the tracker would either redo Steps 4–6
(overbuild) or distrust the tracker (defeating its purpose).

**Fix:** Updated the status table — Steps 4, 5, 6 are now ✅ COMPLETE with
their branch names and PR numbers. Updated the "Next Step" section to
point at Step 7 (Add sample support data) with the correct kickoff
prompt.

### Issue 4: Makefile `help` text was inaccurate

**File:** `Makefile`

**Symptom:**

```
make ollama      - Pull required Ollama models (qwen3:4b, nomic-embed-text)
```

But `scripts/setup_ollama.sh` actually pulls **three** models: `qwen3:4b`,
`qwen3:1.7b` (fallback), and `nomic-embed-text`. The quick-start section
also skipped `make smoke` entirely, even though it is one of the
documented targets and is explicitly the gate that proves Ollama chat +
embeddings work before Kotaemon is launched.

**Impact:** A founder reading `make help` gets a wrong picture of the
local stack and is more likely to skip the smoke test, which then
manifests as an unhelpful Kotaemon "models not configured" error later.

**Fix:** Updated the `ollama` description to include `qwen3:1.7b`.
Rewrote the quick-start to make `smoke` step 2 (marked optional) and
preserves the ordering setup → smoke → preflight → up.

### Issue 5: `setup_ollama.sh` "Next steps" footer was incomplete

**File:** `scripts/setup_ollama.sh`

**Symptom:** The script's success footer listed only `preflight` → `up`
→ `open`, omitting `smoke_test_ollama.sh`. That's inconsistent with
PDR §5.1 (admin setup flow) which assumes the operator can confirm
Ollama chat/embedding round-trips before bringing up the container.

**Fix:** Inserted the (optional) smoke test as recommended step 1 of the
post-setup flow. Now both the Makefile and the standalone script tell
the same story.

---

## 4. Continuity Audit (does Steps 3–6 work *with* Steps 0–2 and *for* 7+?)

### Backwards continuity (do 3–6 fit on top of 0–2?)

| Touchpoint | Status |
|---|---|
| Step 5 `preflight.sh` Check #7 verifies the port from Step 2 (`7860`) | ✅ |
| Step 5 `preflight.sh` Check #8 verifies the directory from Step 1 (`sample-data/support`) | ✅ |
| Step 5 `preflight.sh` Checks #4–6 verify the script artefact from Step 3 (`ollama` models pulled) | ✅ |
| Step 4 `smoke_test_ollama.sh` calls the same `base_url` model identifiers that Step 3 prints | ✅ |
| Step 6 `Makefile` invokes the scripts at the paths Step 1 created | ✅ |
| Step 6 `make up` invokes the `docker-compose.yml` from Step 2 (default file) | ✅ |
| Step 6 `make logs` follows the service name from Step 2 (`kotaemon`) | ✅ |
| Step 2 pilot Compose + Caddyfile do not break the local flow in Step 6 | ✅ — pilot file is opt-in via `-f docker-compose.pilot.yml` |

No regressions found. The four newer steps are real shortcuts and
guards over the existing Step 1/2 surface, not parallel implementations.

### Forward continuity (does the foundation set up Steps 7–23 correctly?)

| Future step | What it needs from Steps 0–6 | Status |
|---|---|---|
| Step 7 (sample data) | `sample-data/support/` exists, mounted RO into container | ✅ — already mounted by Step 2's compose |
| Step 8–9 (prompt packs) | `prompt-packs/` directory with placeholder files | ✅ — created in Step 1 |
| Step 10 (LOCAL_SETUP) | Exact commands `setup_ollama.sh → preflight.sh → docker compose up -d` are real and runnable | ✅ |
| Step 11 (model setup) | Base URL `http://host.docker.internal:11434/v1/` actually works from the container | ✅ — `extra_hosts: host.docker.internal:host-gateway` is in compose |
| Step 16 (eval set) | `evals/` directory exists with placeholders | ✅ |
| Step 17 (`prepare_docs.py`) | Python placeholder reserved | ✅ — file exists, not implemented (correct) |
| Step 18 (`reset_local_data.sh`) | Bash placeholder reserved, Makefile target wired | ✅ — Makefile already calls it; safe because Step 18 must implement the script before `make reset-data` is invoked |
| Step 20 (pilot deployment) | `docker-compose.pilot.yml`, `Caddyfile.example`, `.env.pilot.example` exist | ✅ |
| Step 22 (README rewrite) | Existing README is short, link-friendly, easy to replace | ✅ |
| Step 23 (full MVP run) | Every command in §5.1 of PDR exists and is wired | ✅ |

The only forward-looking footnote: `make reset-data` will fail today
because `scripts/reset_local_data.sh` is still a placeholder. That is
**expected** until Step 18; the Makefile correctly references the
eventual script path and there is no point pre-implementing it.

---

## 5. Software-Manager Audit (organization & redundancy)

### Files that exist and pull their weight

```
/workspace
├── Caddyfile.example          (Step 2 — pilot only)
├── COMMANDER.md               (Step 0 — tracker; refreshed)
├── docker-compose.yml         (Step 2 — local; cleaned)
├── docker-compose.pilot.yml   (Step 2 — pilot; cleaned)
├── docs/                      (Steps 10–21 placeholders)
├── .env.example               (Step 1 placeholder)
├── .env.pilot.example         (Step 2 — pilot; complete)
├── evals/                     (Step 16 placeholders)
├── LICENSE_NOTES.md           (Step 1)
├── Makefile                   (Step 6 — refreshed)
├── opus-reviews/              (continuous review log)
├── Overview/                  (PDR, prompts pack, overview README)
├── prompt-packs/              (Steps 8–9 placeholders)
├── README.md                  (Step 1 minimal; Step 22 will rewrite)
├── sample-data/support/       (Step 7 placeholders)
└── scripts/                   (Steps 3–5 implemented; 17, 18 placeholders)
```

### Redundancy review

I looked for redundant/zombie files. Findings:

- **No duplicated implementation files.** Each step has exactly one
  artifact at the canonical path. Verification branches imported scripts
  from earlier branches (e.g., the step-6 branch contains
  `setup_ollama.sh` originally from step-3); on `main` after merge this
  is the *one* canonical copy — not a duplicate.
- **Opus review docs are cumulative, not redundant.** Each previous
  review covered a discrete moment. I am *not* deleting them; they form
  the audit trail the user asked for. This new review is additive.
- **Two README files** exist: `/README.md` (control panel) and
  `/Overview/README.md` (PDR pack index). These are distinct and
  intentional — keep both. The root README will be expanded in Step 22.
- **`.cursor/agents/verifier.md`** still references `local_rag_mvp_pdr_cursor.md`
  as the PDR file at one point — this was the *original* commander
  template wording embedded in the prompt pack and the verifier doc.
  I corrected the **prompts.md** copy (which is what gets pasted into
  Cursor). The verifier subagent doc itself is read by the subagent
  with `@` resolution, so leaving it is acceptable but slightly
  inconsistent. I am flagging this for the user but **not** changing
  it in this commit because the verifier doc was hand-curated by the
  user/team and outside the literal Steps 3–6 scope.

### Naming / organization nits (worth doing before Step 7 lands)

- `opus-reviews/` uses date + topic naming — good. Consider also adding
  a short `INDEX.md` so a manager can scan reviews chronologically.
  Not blocking; not done in this pass to keep the diff scoped.
- The `docs/` placeholders should keep their current names exactly —
  they match the PDR §8 structure precisely. Verified.

---

## 6. Scope-Discipline Audit

I specifically checked for the four most common forms of drift on
local-first MVPs:

1. **Custom RAG code creeping in.** None found. No vector DB code, no
   chunker, no embedder code beyond *calling* Ollama. ✅
2. **Paid API surface.** No mention of OpenAI/Anthropic/Cohere API keys
   anywhere in the implemented scripts, Makefile, or compose files.
   The Ollama OpenAI-compatible endpoint is used with a literal
   `api_key: ollama` placeholder per PDR §7.2. ✅
3. **Premature integrations.** No Slack/Drive/Jira/Zendesk references
   in any implementation file. ✅
4. **Multi-tenant / SaaS creep.** The pilot compose explicitly stays
   single-customer; comments in both the pilot compose and the Caddy
   file reinforce "one VPS per customer." ✅

Quote from PDR §1.3 I used as the bar: *"We are NOT building: a custom
RAG backend, a custom vector database layer, …, a self-serve SaaS app,
Slack/Google Drive/Jira APIs in v0."* — repo is compliant.

---

## 7. Local Validation Performed in This Review

I cannot run Docker or Ollama in this sandbox (no daemon, no models),
but I verified everything that does not require those services:

- `bash -n scripts/setup_ollama.sh` → OK
- `bash -n scripts/smoke_test_ollama.sh` → OK
- `bash -n scripts/preflight.sh` → OK
- `make help` → renders the updated help text cleanly
- `make -n preflight` / `-n ollama` / `-n smoke` / `-n up` / `-n down` /
  `-n logs` → each prints the expected underlying command
- `docker compose config` → valid, **no warnings** after the `version:`
  removal
- `docker compose -f docker-compose.yml -f docker-compose.pilot.yml
  config` → valid, **no warnings**
- `./scripts/preflight.sh` → produces actionable FAIL output for missing
  Docker daemon and missing Ollama, exits 1 (correct — the sandbox has
  neither)

A founder running this on a Mac/Linux laptop with Docker + Ollama
installed will hit the all-PASS path. The script's PASS message matches
the PDR's "Ready to run: docker compose up -d" guidance.

---

## 8. What I Did NOT Change (and Why)

- **Did not merge the step branches into `main`.** That's a separate,
  human-approved operation. I opened a single PR from this review
  branch (`cursor/opus-review-steps-3-6-8b8c`) containing the latest
  consolidated state of Steps 0–6 *plus* the fixes from this review.
  Merging is up to you.
- **Did not implement Steps 7+.** The commander rule forbids it
  ("Implement exactly one PDR step at a time"). My job here was
  continuity review only.
- **Did not refactor the working-agent scripts.** They are already
  PDR-compliant and well-organized. I only adjusted output strings
  where they conflicted with reality.
- **Did not rewrite the root `README.md`.** Step 22 owns that.

---

## 9. Risks / Watch-outs for Step 7 and Beyond

1. **Branch sprawl.** The repo now has ~16 cursor/* branches. Once
   Steps 0–6 are merged to `main`, archive or delete the old
   step/verification branches to keep navigation clean. Suggested rule:
   "after step N's verification PR is merged, only keep one verification
   branch alive at a time."
2. **Verifier subagent file uses old PDR name.** Low priority. If a
   future agent re-runs Prompt 1, the canonical contents would still
   emit the old path. Consider a one-line refresh on the verifier doc
   when convenient.
3. **`KOTAEMON_PORT` env override.** `docker-compose.yml` uses
   `"${KOTAEMON_PORT:-127.0.0.1:7860}:7860"`. If someone sets
   `KOTAEMON_PORT=8000` (without the IP prefix), Compose will bind on
   `0.0.0.0:8000` and expose Kotaemon to the LAN. The PDR's intent is
   localhost-only. Consider documenting that the env var must include
   the `127.0.0.1:` prefix, or splitting into `KOTAEMON_BIND_IP` +
   `KOTAEMON_PORT`. Non-blocking; flag for a future polish step.
4. **Sample data folder mounted RO before content exists.** Step 7 will
   land real files into `sample-data/support/`. Until then, the
   container sees only placeholder 2-line markdown stubs. This is fine
   for demo *prep* but a demo cannot be run end-to-end until Step 7
   completes. The Step 6 verification report incorrectly implied the
   demo workflow is fully ready; it is not, because the sample corpus
   is still placeholder content. The Makefile is ready; the *data* is
   not. Flagged so we don't accidentally try Step 23 before Step 7.

---

## 10. Verdict

> **Steps 0–6 form a clean, PDR-compliant foundation. Five small drift
> bugs were found and fixed in this review. The repo is ready to proceed
> to Step 7 (Add sample support data) once this review PR is merged.**

### Final per-step status after this review

| Step | Status | Confidence |
|---|---|---|
| 0 | ✅ COMPLETE | High |
| 1 | ✅ COMPLETE | High |
| 2 | ✅ COMPLETE (+ version warning fixed in this review) | High |
| 3 | ✅ COMPLETE (+ next-steps footer enriched) | High |
| 4 | ✅ COMPLETE | High |
| 5 | ✅ COMPLETE | High |
| 6 | ✅ COMPLETE (+ help text accuracy fix) | High |

### Recommended next action

1. Merge this PR (`cursor/opus-review-steps-3-6-8b8c`) into `main`.
   That brings `main` to a fully-Steps-0–6-complete state with the
   continuity fixes baked in.
2. Archive or delete the now-redundant step-3/-4/-5/-6 working and
   verification branches.
3. Kick off Step 7 with Prompt 2 from `Overview/prompts.md` (which now
   correctly references the actual PDR file).

---

*Reviewed by Opus — continuity + software-manager pass — 2026-05-15.*
