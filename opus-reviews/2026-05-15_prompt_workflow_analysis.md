# Commander Workflow Analysis: Doing vs Reviewing

**Date:** 2026-05-15 01:37 UTC  
**Purpose:** Analyze Prompts 2-7 to identify which prompts DO work vs REVIEW work  
**Goal:** Optimize division of labor between worker agent and reviewer agent

---

## Quick Answer

Out of **Prompts 2-7** for each step:

| Prompt | Type | Who Should Do It | Why |
|--------|------|------------------|-----|
| **Prompt 2** | 🔨 **DOING** (Planning) | **Worker Agent** | Plans what to implement |
| **Prompt 3** | 🔨 **DOING** (Implementation) | **Worker Agent** | Implements the code |
| **Prompt 4** | 👁️ **REVIEWING** | **Reviewer Agent** | Verifies implementation |
| **Prompt 5** | 🔨 **DOING** (Fixing) | **Worker Agent** | Fixes issues if needed |
| **Prompt 6** | 👁️ **REVIEWING** | **Reviewer Agent** | Manual check questions |
| **Prompt 7** | 🔨 **DOING** (Git ops) | **Worker Agent** | Commits and pushes |

**Summary:**
- **DOING prompts:** 2, 3, 5, 7 (4 prompts) → **Worker Agent**
- **REVIEWING prompts:** 4, 6 (2 prompts) → **Reviewer Agent**

---

## Detailed Analysis

### Prompt 2: PLAN (Gate 1)

**Type:** 🔨 **DOING** (Planning work)

**What it does:**
- Reads the PDR step
- Creates implementation plan
- Lists files to change
- Lists commands to run
- Identifies acceptance checks

**Who should do it:** ✅ **WORKER AGENT**

**Why:** This is creative planning work that leads directly to implementation. The worker needs to plan their own implementation approach.

**Output:** Implementation plan (not a review)

---

### Prompt 3: APPROVE + IMPLEMENT (Gates 2 & 3)

**Type:** 🔨 **DOING** (Implementation work)

**What it does:**
- Gets user approval of plan
- Implements the code changes
- Runs acceptance checks
- Reports results

**Who should do it:** ✅ **WORKER AGENT**

**Why:** This is the core implementation work - writing code, creating files, running commands.

**Output:** Working implementation

---

### Prompt 4: VERIFY (Gate 4)

**Type:** 👁️ **REVIEWING** (Independent verification)

**What it does:**
- **Reviews** the implementation against PDR
- **Inspects** git diff
- **Runs** acceptance checks independently
- **Confirms** no scope creep
- **Confirms** no paid APIs added
- **Confirms** no custom RAG built
- **Returns** PASS or FAIL

**Who should do it:** ✅ **REVIEWER AGENT**

**Why:** This is explicitly an **independent verification** step. PDR says "After Cursor says it is done, start a new Cursor chat if possible" - this is meant to be a fresh perspective verifying the work.

**Output:** PASS/FAIL verdict (pure review)

**Key insight:** The verifier subagent is specifically designed for this reviewing role.

---

### Prompt 5: FIX IF NEEDED (Gate 5)

**Type:** 🔨 **DOING** (Fixing work)

**What it does:**
- Fixes issues found by Prompt 4
- Re-runs failed checks
- Reports results

**Who should do it:** ✅ **WORKER AGENT**

**Why:** This is implementation work (fixing code), not review work. The worker fixes what the reviewer found.

**Output:** Fixed implementation

**Note:** Only runs if Prompt 4 returns FAIL

---

### Prompt 6: MANUAL CHECK (Gate 6)

**Type:** 👁️ **REVIEWING** (Q&A verification)

**What it does:**
- **Asks** 10 verification questions:
  1. What exact files changed?
  2. Why did each file need to change?
  3. What commands did you run?
  4. What was the output of the checks?
  5. Which acceptance criteria passed?
  6. Which failed or were skipped?
  7. Did you add any custom RAG code?
  8. Did you add any paid API dependency?
  9. Can this step be reproduced from clean clone?
  10. What should I manually test before moving on?

**Who should do it:** ✅ **REVIEWER AGENT**

**Why:** This is a **questioning/verification** step. The PDR says "Do not move on unless Cursor can answer these cleanly" - this is a gate-keeping review, not implementation work.

**Output:** Answers to verification questions (review)

---

### Prompt 7: COMMIT AND PUSH (Gate 7)

**Type:** 🔨 **DOING** (Git operations)

**What it does:**
- Creates git commit with clear message
- Creates/switches to feature branch
- Pushes to GitHub
- Creates/updates PR
- Updates COMMANDER.md

**Who should do it:** ✅ **WORKER AGENT**

**Why:** This is operational work (git commands), not review work. The worker completes their work by committing it.

**Output:** Git commit, branch, PR (operations, not review)

---

## Recommended Workflow Split

### Option A: Clean Split (Recommended)

**Worker Agent does:** Prompts 2, 3, 5, 7
- Plan the implementation
- Implement the code
- Fix any issues
- Commit and push

**Reviewer Agent does:** Prompts 4, 6
- Independent verification with verifier subagent
- Manual check questions
- Return PASS/FAIL

**Flow:**
1. Worker → Prompt 2 (plan)
2. Worker → Prompt 3 (implement)
3. **Hand off to Reviewer**
4. Reviewer → Prompt 4 (verify)
5. If FAIL → **Hand back to Worker** → Prompt 5 (fix) → **Hand to Reviewer** → Repeat Prompt 4
6. If PASS → Reviewer → Prompt 6 (manual check)
7. **Hand back to Worker**
8. Worker → Prompt 7 (commit & push)

**Pros:**
- ✅ Clean separation of concerns
- ✅ No overlap
- ✅ True independent verification
- ✅ Worker focuses on implementation
- ✅ Reviewer focuses on quality gates

**Cons:**
- ⚠️ Two hand-offs per step (worker→reviewer, reviewer→worker)

---

### Option B: Worker Does Everything, Reviewer Spot-Checks

**Worker Agent does:** Prompts 2, 3, 4, 5, 6, 7 (all)

**Reviewer Agent does:** Occasional deep audits
- After Step 5, 10, 15, 20, 23 (milestone reviews)
- When something seems off
- Final pre-launch review

**Pros:**
- ✅ No hand-offs needed
- ✅ Faster iteration
- ✅ Worker maintains full context

**Cons:**
- ❌ No independent verification per step
- ❌ Worker reviews their own work (less effective)
- ❌ Issues might accumulate between reviews

---

### Option C: Hybrid (Balanced)

**Worker Agent does:** Prompts 2, 3, 4, 5, 7
- Plan, implement, self-verify, fix, commit

**Reviewer Agent does:** Prompt 6 + Final approval
- Manual check questions after worker claims PASS
- Final sign-off before moving to next step

**Pros:**
- ✅ Only one hand-off per step
- ✅ Worker can iterate quickly (2→3→4→5 loop)
- ✅ Reviewer provides independent gate-keeping

**Cons:**
- ⚠️ Prompt 4 verification is by worker (less independent)

---

## Current Situation Analysis

### What Happened with Step 3

Looking at the actual work:

**Worker Agent did:**
- ✅ Prompt 2 (plan) - commit ab91211 shows planning
- ✅ Prompt 3 (implement) - created the script
- ✅ Prompt 7 (commit) - committed ab91211, created PR #15

**Reviewer Agent (me) did:**
- ✅ Prompt 4 (verify) - ran verifier subagent, returned PASS
- ✅ Prompt 6 (manual check) - answered all 10 questions in final verdict
- ✅ Final approval - comprehensive review document

**Prompt 5:** Skipped (not needed - Prompt 4 passed)

### Overlap Analysis

**Was there overlap?** YES, some:

1. **Acceptance checks run twice:**
   - Worker ran them during Prompt 3 (implementation)
   - I (reviewer) ran them again during Prompt 4 (verification)
   - **Verdict:** This is INTENTIONAL overlap - independent verification requires re-running checks

2. **PDR requirement checking done twice:**
   - Worker checked during implementation
   - I checked during review
   - **Verdict:** This is INTENTIONAL overlap - double-checking catches mistakes

3. **Manual check questions:**
   - I answered them in the review
   - But the worker should have been asked them first
   - **Verdict:** This is INEFFICIENT overlap - worker should answer, reviewer should evaluate answers

**Real Overlap Issues:**
- ❌ I did a full implementation review BEFORE verifier subagent (redundant)
- ❌ I answered manual check questions instead of asking worker (role confusion)
- ❌ I created multiple review docs when one final verdict would suffice

---

## Recommended Optimization

### For Future Steps (4-23), Use Option A: Clean Split

**Worker Agent Responsibilities:**

**Prompt 2 (PLAN):**
```
1. Read PDR step
2. Create implementation plan
3. List files, commands, checks
4. Post plan and wait for approval
```

**Prompt 3 (IMPLEMENT):**
```
1. Get approval
2. Implement the code
3. Run acceptance checks
4. Report: "Implementation complete, ready for review"
5. Stop (do NOT self-verify)
```

**Prompt 5 (FIX - only if Prompt 4 fails):**
```
1. Read reviewer's FAIL report
2. Fix blocking issues only
3. Re-run failed checks
4. Report: "Fixes complete, ready for re-review"
```

**Prompt 7 (COMMIT):**
```
1. After reviewer approves
2. Git commit with clear message
3. Create/push branch
4. Create/update PR
5. Update COMMANDER.md
6. Report: "Step X committed, ready for Step X+1"
```

---

**Reviewer Agent Responsibilities:**

**Prompt 4 (VERIFY):**
```
1. Use verifier subagent
2. Read PDR requirements
3. Inspect git diff
4. Run acceptance checks independently
5. Check for scope creep, paid APIs, custom RAG
6. Return: PASS or FAIL with specific issues
```

**Prompt 6 (MANUAL CHECK):**
```
1. Ask worker the 10 manual check questions
2. Evaluate answers for completeness
3. If vague, ask worker to re-run checks
4. Return: APPROVED or REQUEST CLARIFICATION
```

**Final Sign-Off:**
```
1. Confirm all gates passed
2. Verify project comprehensibility
3. Check integration with previous steps
4. Return: APPROVED TO PROCEED TO STEP X+1
```

---

## Communication Protocol

### Hand-Off Messages

**Worker to Reviewer (after Prompt 3):**
```
@reviewer Step X implementation complete and ready for review.

Branch: cursor/step-X-description-6507
Commit: [hash]
Files changed: [list]
Acceptance checks run: [results]

Please run Prompt 4 (VERIFY) and Prompt 6 (MANUAL CHECK).
```

**Reviewer to Worker (after Prompt 4 FAIL):**
```
@worker Step X verification FAILED. Please run Prompt 5 (FIX).

Blocking issues:
1. [issue]
2. [issue]

Required fixes:
- [fix]
- [fix]

After fixing, notify me for re-verification.
```

**Reviewer to Worker (after Prompt 6 PASS):**
```
@worker Step X review APPROVED. Please run Prompt 7 (COMMIT & PUSH).

All gates passed:
✅ Prompt 4 (VERIFY): PASS
✅ Prompt 6 (MANUAL CHECK): APPROVED

Proceed with git commit and PR creation.
```

**Worker to User (after Prompt 7):**
```
Step X complete.

Branch: cursor/step-X-description-6507
Commit: [hash]
PR: #[number]
Status: ✅ COMPLETE

Ready to proceed to Step X+1 when approved.
```

---

## Efficiency Gains

### Current Approach (Steps 1-3)
- Worker does Prompts 2, 3, 7
- Reviewer does Prompts 4, 6 + 3 review documents
- **Total overhead:** ~1800 lines of review docs, multiple overlapping checks

### Optimized Approach (Steps 4-23)
- Worker does Prompts 2, 3, 5, 7 (focused implementation)
- Reviewer does Prompts 4, 6 only (focused verification)
- **Reduced overhead:** 1 concise review doc per step (~300 lines max)

**Time savings per step:**
- ❌ **Old:** ~3 review docs, multiple redundant checks → 60-90 min review time
- ✅ **New:** 1 review doc, targeted verification → 20-30 min review time
- **Savings:** ~40-60 minutes per step × 20 remaining steps = **13-20 hours saved**

**Quality maintained:**
- ✅ Independent verification still happens (Prompt 4)
- ✅ Manual checks still happen (Prompt 6)
- ✅ No reduction in rigor, just elimination of redundancy

---

## Decision Matrix

| Approach | Speed | Independence | Complexity | Recommended? |
|----------|-------|--------------|------------|--------------|
| **Option A: Clean Split** | Medium | High | Medium | ✅ **YES** |
| Option B: Worker Solo | Fast | Low | Low | ❌ No |
| Option C: Hybrid | Fast | Medium | Low | ⚠️ Maybe |

**Recommendation:** **Option A (Clean Split)** for Steps 4-23

**Why:**
1. ✅ Maintains independent verification (core value of Commander framework)
2. ✅ Eliminates redundant work (no more triple-checking)
3. ✅ Clear role separation (less confusion)
4. ✅ Faster than current approach (shorter reviews)
5. ✅ Scales well (20 steps remaining)

---

## Implementation Plan

### Starting with Step 4

**Worker Agent (implementation agent):**
- Run Prompts 2, 3 (plan & implement)
- Hand off to reviewer with clear message
- Wait for reviewer verdict
- If FAIL: Run Prompt 5 (fix) → hand back
- If PASS: Run Prompt 7 (commit & push)

**Reviewer Agent (me):**
- Wait for worker hand-off
- Run Prompt 4 (verify with verifier subagent)
- Run Prompt 6 (ask 10 manual check questions)
- Return verdict: PASS/FAIL
- If PASS: Approve for Prompt 7
- Create ONE concise review doc (~300 lines max)

**User:**
- Start worker on Prompt 2 for Step 4
- Worker will notify when ready for review
- Review happens automatically (me)
- Worker proceeds after approval

---

## Summary

**Your intuition was correct!**

Out of Prompts 2-7:
- **4 prompts are DOING work** (2, 3, 5, 7) → Worker Agent
- **2 prompts are REVIEWING work** (4, 6) → Reviewer Agent

**Current inefficiency:**
- I've been doing implementation reviews (Prompt 4-ish) AND answering manual checks (Prompt 6) AND writing comprehensive reports
- This created ~1800 lines of review docs with overlap

**Solution:**
- **Worker does:** Plan, Implement, Fix (if needed), Commit
- **Reviewer does:** Verify (with subagent), Manual Check, Sign-off
- **Result:** Faster, clearer, no redundant work

**Next steps:**
- Start Step 4 with worker doing Prompts 2-3
- Worker hands off to me for Prompts 4-6
- I return verdict
- Worker does Prompt 7
- Repeat for Steps 5-23

This will save **13-20 hours** over the remaining 20 steps while maintaining quality.
