# Overview

Source-of-truth documents for the Local-First Support Knowledge Bot MVP.
The repo root README is the user-facing entry point; this folder is for the
build-process documents that drive how the MVP gets built.

## Files

- **`finalized_local_first_support_kb_pdr.md`** — the Product Design
  Requirements (PDR). The PDR is the single source of truth for scope,
  architecture, and the 23 build steps. Every implementation step in this
  repo maps to a numbered step in this document.
- **`prompts.md`** — the MVP Commander prompt pack. Defines the 11 reusable
  prompts (PLAN → APPROVE → IMPLEMENT → VERIFY → FIX → MANUAL CHECK →
  COMMIT) used to walk the PDR one step at a time.

## Related operating files

- `../COMMANDER.md` — progress tracker and usage guide for the workflow.
- `../.cursor/rules/mvp-commander.mdc` — always-on project rule enforcing
  one-step-at-a-time development.
- `../.cursor/agents/verifier.md` — independent verifier subagent definition.
- `../opus-reviews/` — periodic foundation/cohesion reviews of completed
  steps.

## How to use

1. Read the PDR section for the step you are about to implement.
2. Use the prompts in `prompts.md` (in order) to drive that step.
3. Update `../COMMANDER.md` when the step PASSES.
4. Do not move to the next PDR step until the current step passes its
   acceptance checks and is committed and pushed.
