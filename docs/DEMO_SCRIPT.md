# Demo Script

This is the standard 10-minute sales demo. For a real prospect call, use the
`demo-hosted` profile so the product feels fast and reliable. Use `dev-ollama`
only for personal rehearsal.

## Profile Choice

| Situation | Profile | Rule |
|---|---|---|
| Personal testing or private rehearsal | `dev-ollama` | Good for checking flow, not for selling speed |
| Prospect demo | `demo-hosted` | Default for sales demos |
| Paid customer pilot | `pilot-hosted` | Default for production-speed pilots |
| Customer forbids hosted inference | `pilot-private-gpu` | Only after GPU path passes the speed target |

## Demo Setup For Prospect Calls

Before the call:

1. Start Kotaemon with `docker compose up -d`.
2. Open `http://localhost:7860` or the demo host URL.
3. Configure Kotaemon Resources with `config/inference/demo-hosted.example.yml`.
4. Create a collection named `support-demo`.
5. Upload these sample docs:
   - `sample-data/support/01_refund_policy.md`
   - `sample-data/support/02_sso_escalation_sop.md`
   - `sample-data/support/03_billing_macros.csv`
   - `sample-data/support/04_release_notes.md`
   - `sample-data/support/05_solved_tickets.csv`
   - `sample-data/support/06_support_onboarding.md`
6. Wait for indexing to finish.
7. Paste `prompt-packs/support_v1.md` into the Kotaemon QA/system prompt field.
8. Ask two warm-up questions and confirm answers are cited and responsive.

For personal rehearsal only, run `./scripts/setup_ollama.sh`,
`./scripts/preflight.sh`, and configure `config/inference/dev-ollama.example.yml`.
Do not use laptop latency as the production-speed story.

## Opening Positioning

Use this line:

> This is a private support knowledge bot for approved docs your team already trusts. It finds the right source, drafts an internal answer, and gives a customer-ready reply when the docs support one.

Do not position v0 as full Glean, a custom RAG platform, or a live workspace
connector product.

## 10-Minute Flow

### Minute 0-1: Show the corpus

Open the collection and show the six uploaded sample files. Point out that the
docs are fake but shaped like real support sources: policies, SOPs, macros,
release notes, tickets, and onboarding.

### Minute 1-2: Show the prompt format

Open `prompt-packs/support_v1.md`. Explain that the bot must answer only from
retrieved sources and must return:

- Internal answer.
- Customer-ready reply.
- Sources used.
- Confidence.
- Escalation guidance.
- Suggested tag or macro.
- Missing-doc note.

### Minute 2-8: Ask the demo questions

Ask these in order.

1. **Can we refund a customer after 20 days?**
   - Good answer: cites `01_refund_policy.md`; says monthly self-serve plans are eligible within 30 days if no exception applies; includes customer-ready wording.

2. **Can we refund an annual enterprise customer without approval?**
   - Good answer: cites `01_refund_policy.md`; says no; requires Finance Director approval and assigned CSM escalation.

3. **What should I do if a customer has an SSO group sync issue?**
   - Good answer: cites `02_sso_escalation_sop.md`; lists scope confirmation, configuration check, manual SCIM sync, release-note check, and escalation conditions.

4. **What changed in the latest SSO release?**
   - Good answer: cites `04_release_notes.md`; says release 2026.05 changed nested IdP group handling by flattening nested groups.

5. **Write a customer-ready reply for a failed invoice payment.**
   - Good answer: cites `03_billing_macros.csv`; uses the failed invoice payment retry macro; mentions updating payment method, retrying payment, and the 7-day grace window.

6. **What tag should I use for a refund request?**
   - Good answer: cites `01_refund_policy.md`, `03_billing_macros.csv`, or solved tickets; suggests tags such as `refund-processed`, `refund-pending-approval`, `refund-credit-offer`, or `chargeback-in-progress` depending on scenario. If the question is too broad, a good answer asks for the refund scenario.

7. **Is there a Berlin office lunch policy?**
   - Expected answer: `Not enough source support.` The docs do not contain a Berlin office lunch policy.

### Minute 8-9: Show citations and source preview

For one successful answer:

1. Point to `Sources used`.
2. Open the cited source document in Kotaemon.
3. Confirm the cited passage supports the claim.
4. Explain that citations are the product: if the answer cannot be traced back, the support rep should not use it.

### Minute 9-10: Show how bad answers are handled

If an answer is wrong or weak, say:

> This is why the pilot starts with 20 known questions and source cleanup. We improve quality first by fixing docs, removing conflicts, and tightening the prompt before writing custom code.

Do not improvise unsupported claims. If the bot misses a source, open the source
manually and treat it as a retrieval/doc-quality issue to log.

## Demo Pass Conditions

- Questions 1-6 return source-backed answers.
- Question 7 refuses with `Not enough source support`.
- At least one answer shows a usable customer-ready reply.
- At least one citation/source preview is opened live.
- Latency is acceptable on the hosted demo profile before a prospect sees it.
- Any weak answer is framed as a doc or prompt refinement item, not hidden.
