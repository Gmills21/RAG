# Group 3 Prompts Evaluation - Step 3

**Date:** 2026-05-15  
**PDR Step:** Step 3 - Add Ollama setup script  
**Purpose:** Determine if optional Group 3 review prompts are needed

---

## Group 3 Overview

Group 3 contains **optional review prompts** used when extra scope control, dependency audit, or product-quality review is needed.

**Available prompts:**
- **Prompt 8:** "Do not overbuild" (re-scope)
- **Prompt 9:** "No paid API" audit
- **Prompt 10:** Citation / source preview check

**From prompts.md line 373:**
> Use Group 3 when you need extra scope control, dependency audit, or product-quality review — not on every step. (If Prompt 4 fails, use Prompt 5 in Group 2 first; that is the required fix loop, not optional.)

---

## Evaluation Criteria

### When to Use Group 3 Prompts

**Prompt 8 (Re-scope):** Use when:
- Implementation went beyond PDR step scope
- Custom RAG logic was added
- Integrations/auth/billing added without PDR requirement
- Custom UI/vector DB/chat systems built
- Agent shows signs of overbuilding

**Prompt 9 (Paid API audit):** Use after:
- Steps touching models, env, Docker, config, or docs
- Any changes to .env files
- Any changes to docker-compose.yml
- Any changes to scripts that might use APIs
- Any updates to documentation about models/APIs

**Prompt 10 (Citation check):** Use when:
- The app is running and can be tested
- After RAG/retrieval features are implemented
- Sample docs can be uploaded
- Questions can be asked and answers reviewed
- Step 23 or later (full MVP run)

---

## Step 3 Evaluation

### Prompt 8: "Do not overbuild" - NOT NEEDED ✅

**Analysis:**

**Files changed:**
- `scripts/setup_ollama.sh` only
- `STEP_3_VERIFICATION.md` (documentation)

**Scope check:**
- ✅ Script only automates Ollama setup
- ✅ No custom RAG system added
- ✅ No vector database logic
- ✅ No custom chat UI
- ✅ No integrations (Slack/Drive/Jira)
- ✅ No auth/billing systems
- ✅ No cloud deployment logic
- ✅ Script is a simple wrapper around `ollama` CLI

**PDR Step 3 requirements (lines 665-682):**
- Check ollama command ✅
- Check server running ✅
- Pull 3 models ✅
- List models ✅
- Print config ✅

**Verifier finding:** "Implementation stayed strictly within PDR Step 3 boundaries"

**Conclusion:** No overbuilding detected. Script does exactly what PDR Step 3 requires, nothing more.

**Prompt 8 needed:** ❌ NO

---

### Prompt 9: "No paid API" audit - NEEDED ✅

**Analysis:**

**Trigger conditions met:**
- ✅ Step touches models (pulls qwen3:4b, qwen3:1.7b, nomic-embed-text)
- ✅ Step touches config (prints Kotaemon configuration)
- ✅ Script could potentially introduce API dependencies
- ✅ Documentation mentions API keys and base URLs

**Files to audit:**
- `scripts/setup_ollama.sh`
- `.env.example` (to verify no new vars added)
- `docker-compose.yml` (to verify no changes)
- Any other config files

**Reason for audit:**
Even though verifier confirmed no paid APIs, Prompt 9 provides an additional systematic audit specifically focused on paid API dependencies, which is critical for the MVP's "local-first, no paid APIs by default" principle.

**Prompt 9 needed:** ✅ YES (recommended for thoroughness)

---

### Prompt 10: Citation / source preview - NOT NEEDED ✅

**Analysis:**

**Trigger conditions:**
- ❌ App is NOT running yet
- ❌ RAG/retrieval features NOT yet implemented
- ❌ Sample docs cannot be uploaded yet
- ❌ Cannot ask questions and review answers yet

**Current status:**
- Step 3 only adds Ollama setup script
- Kotaemon not yet configured or tested
- No documents uploaded
- No retrieval workflow available

**When needed:**
- After Step 22 (README complete)
- During Step 23 (full MVP run)
- When app is actually running with uploaded docs

**Conclusion:** Too early for citation testing.

**Prompt 10 needed:** ❌ NO (defer to Step 23)

---

## Summary

### Group 3 Prompts for Step 3

| Prompt | Name | Needed | Reason |
|--------|------|--------|--------|
| Prompt 8 | "Do not overbuild" | ❌ NO | No scope creep, stayed within PDR Step 3 |
| Prompt 9 | "No paid API" audit | ✅ YES | Step touches models and config - systematic audit recommended |
| Prompt 10 | Citation check | ❌ NO | Too early - app not running yet |

### Recommendation

**Execute Prompt 9 only.**

**Rationale:**
- Step 3 touches models and configuration (Prompt 9 trigger)
- Verifier already checked for paid APIs, but Prompt 9 provides systematic file-by-file audit
- Adds extra assurance for the critical "no paid APIs by default" principle
- Low cost, high confidence benefit
- Prompts 8 and 10 are not applicable at this stage

---

## Next Actions

1. ✅ Execute Prompt 9: "No paid API" audit
2. ✅ Document Prompt 9 results
3. ✅ Commit Prompt 9 documentation
4. ✅ Update PR with Group 3 evaluation
5. → Proceed to PDR Step 4

---

## For Reviewing Agent

This evaluation determined that **Prompt 9 (paid API audit)** should be executed for Step 3.

**Verification checklist:**
- [x] Evaluated all three Group 3 prompts
- [x] Provided clear reasoning for each
- [x] Identified which prompts are needed
- [x] Explained why others are not needed
- [x] Documented decision process

**Expected next document:** `STEP_3_PROMPT_9_AUDIT.md`
