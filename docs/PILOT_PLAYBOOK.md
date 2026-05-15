# Pilot Playbook

Positioning line:

> We deploy a private AI answer bot from the docs your team already trusts. No full workspace integration required.

Use this playbook to turn the local MVP into a narrow, founder-led first pilot.
The product promise is not "AI for everything." The promise is faster support
answers from approved support knowledge with citations.

## Clean Product Path

- Use `dev-ollama` only for personal testing and private rehearsal.
- Use `demo-hosted` for prospect demos.
- Use `pilot-hosted` for first paid pilots by default.
- Use `pilot-private-gpu` only when a customer forbids hosted inference and the GPU host can meet the same speed target.

The first pilot should prove cited support answers from approved docs, not prove
that a laptop model can be fast enough for production.

## Who This MVP Is For

- B2B SaaS support, success, implementation, or operations teams.
- Teams with repeated internal support questions.
- Teams that already have SOPs, macros, help-center docs, release notes, or
  solved-ticket exports.
- Teams willing to curate a small source-of-truth corpus before rollout.
- Teams that value cited answers over broad workspace search.

## Who This MVP Is Not For

- Teams that need live Slack, Drive, Jira, Zendesk, or Confluence sync on day 1.
- Teams that need the bot to take account actions or change production data.
- Teams that cannot identify trusted source docs.
- Teams that require multi-tenant SaaS, SSO, audit logs, and admin analytics in
  the first pilot.
- Teams that want to upload everything and let the model sort it out.

## First-Pilot Scope

- Duration: 30 days.
- Price: $1,500 to $5,000 setup/pilot.
- Users: one team, 5 to 25 users.
- Data sources: approved docs plus optional CSV exports only.
- Default setup: founder-operated local instance for private validation, hosted
  inference for prospect demos, then a dedicated single-customer VPS using
  `pilot-hosted` for the first real pilot.
- Out of scope: broad workspace integrations, multi-tenant SaaS, custom RAG
  engine work, billing, and production workflow automation.

## 30-Day Pilot Structure

### Week 0: Source Prep And Baseline

- Send `docs/CUSTOMER_ONBOARDING.md`.
- Collect only approved docs and optional solved-ticket CSV exports.
- Run `docs/SOURCE_QUALITY_CHECKLIST.md`.
- Ask the customer to define 20 known questions and expected source docs.
- Prepare docs with `scripts/prepare_docs.py` if conversion is useful.
- Choose the inference path: `pilot-hosted` by default, `pilot-private-gpu` only
  if hosted inference is contractually blocked.

### Week 1: Private Validation

- Upload the approved corpus.
- Configure the support prompt pack and the selected production inference profile.
- Run the 20 known questions with the customer sponsor.
- Log missing docs, stale docs, weak answers, and strong answers.
- Do not add broad integrations to fix source-quality problems.

### Week 2: Small Team Trial

- Invite 5 to 10 support users.
- Ask users to use the bot for real repeated questions.
- Save useful answers and bad answers.
- Keep a list of missing or outdated source docs.

### Week 3: Tune The Corpus

- Remove confusing, duplicate, or stale docs.
- Add missing source-of-truth docs approved by the customer.
- Re-run the known questions and the highest-value real questions.
- Confirm citations are useful enough for reps to trust.

### Week 4: Decision Review

- Review pilot metrics.
- Decide whether to continue, expand, or stop.
- If continuing, propose a paid private deployment and a limited roadmap.
- If answer quality is bad, fix source quality before building new features.

## Success Metrics

The pilot is successful when the customer confirms meaningful support value and
these metrics are met or clearly trending:

- 100 real questions asked.
- 10 useful saved answers.
- 5 missing/outdated docs identified.
- Customer confirms it reduces repeated questions.
- Standard cited questions feel fast enough for daily use on the production profile.

Optional supporting signals:

- Newer reps can answer common questions with less senior escalation.
- The team trusts cited answers more than uncited chat output.
- The customer can name one workflow where the bot should stay available.

## Weekly Check-In Template

Use this agenda each week:

```text
Customer:
Week:
Active users:
Questions asked:
Useful answers saved:
Bad answers reviewed:
Missing/outdated docs found:
Top 3 repeated questions:
Docs to add/remove before next check-in:
Risks or concerns:
Decision needed from customer:
```

Ask these questions:

- What answer saved someone time this week?
- What answer was wrong, risky, or unsupported?
- Which source doc should have existed but did not?
- Did any cited source surprise or confuse the team?
- Should we narrow, continue, or expand the pilot next week?

## End-Of-Pilot Conversion Script

Use this script in the final review:

```text
We proved the bot can answer repeated support questions from the docs your team already trusts.

In 30 days, your team asked [count] questions, saved [count] useful answers, and identified [count] missing or outdated docs. The next step is a private single-customer deployment with the same approved-docs scope, stronger access control, and a monthly support/tuning cadence.

We should not add broad workspace integrations yet unless they support this exact workflow. First, we keep the source set clean and make the cited-answer loop reliable for your team.
```

## If Answer Quality Is Bad

Do this before changing product scope:

1. Check whether the source document exists.
2. Check whether the retrieved source is current and trusted.
3. Remove conflicting or stale docs.
4. Add the missing source-of-truth doc if the customer has one.
5. Re-run the known question.
6. Log the issue as retrieval, source quality, prompt format, or missing data.

Do not promise custom RAG logic as the first fix. Most early failures should be
handled by better source curation, clearer prompts, or narrower pilot scope.

## If The Customer Asks For Slack, Drive, Jira, Or Zendesk APIs

Use this response:

```text
That may be a good later integration, but it is not the first pilot. The first pilot proves whether cited answers from approved docs reduce repeated support questions. If that works, we can prioritize the smallest connector that feeds the same approved source-of-truth workflow.
```

Keep the data source limit: approved docs plus optional CSV exports only.

## If The Customer Asks About Hosted Inference

Use this response:

```text
For the pilot, we use only the approved docs you send us. The private app retrieves relevant chunks from those docs and sends the question plus those chunks to the configured hosted inference endpoint so answers are fast enough for daily use. We do not request full workspace access. If hosted inference is not allowed, we can scope a private GPU pilot, but we will only use it if it meets the same speed and quality bar.
```

Record the approved inference endpoint in the pilot notes before launch.

## Deployment Path

- Use founder-operated local instance for personal testing and guided validation.
- Use `demo-hosted` for prospect demos.
- Use a dedicated single-customer VPS plus `pilot-hosted` for the first real pilot.
- Use private GPU or customer-owned server/VPN only when required.
- Do not build multi-tenant SaaS in v0.

See `docs/PILOT_DEPLOYMENT.md` for the VPS path.

## Pilot Readiness Checklist

- [ ] Customer sponsor agrees the scope is one team and 5 to 25 users.
- [ ] Customer approves the provided docs for pilot use.
- [ ] No full workspace export is requested.
- [ ] The source corpus follows `docs/SOURCE_QUALITY_CHECKLIST.md`.
- [ ] The team has 20 known questions before launch.
- [ ] Demo and pilot data are separated.
- [ ] Pilot uses `pilot-hosted` or a documented customer-approved equivalent.
- [ ] Pilot success metrics are written down.
- [ ] Access control and production-speed check passed before inviting users.
- [ ] Bad-answer review process is agreed before rollout.
