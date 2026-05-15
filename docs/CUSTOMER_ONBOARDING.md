# Customer Onboarding Guide

Use this guide to onboard a pilot customer without asking for broad workspace access. The product works best when the first corpus is small, current, and trusted.

## Customer-Facing Message

Send this before requesting files:

> We do not need access to your whole workspace. Send us only the approved docs your team already trusts.

Position the pilot as a curated support knowledge test, not a full enterprise-search rollout. The customer should understand that v0 uses manual upload plus optional CSV exports.

For paid pilots, also explain the inference path in plain language: the private
app retrieves relevant excerpts from the approved docs and sends the question
plus those excerpts to the configured customer-approved inference endpoint. If
that is not allowed, the pilot needs a separate private-GPU scope.

## What We Ask The Customer To Send

Ask for a ZIP folder or shared export that contains only approved support material:

- Internal support SOPs.
- Help center articles and product docs.
- Support macros and approved response templates.
- Refund, billing, security, escalation, and account policies.
- Support onboarding docs.
- Troubleshooting guides and known issue notes.
- Release notes and changelogs.
- Optional solved-ticket CSV exports.

Do not ask for direct Slack, Google Drive, Jira, Zendesk, or Confluence access for v0. If the customer asks about integrations, explain that connectors are a later phase after the pilot proves value with curated docs.

## What To Include First

Start with the smallest corpus that answers common support questions:

- Current policies that support reps already follow.
- Current SOPs for the top 5 to 10 ticket categories.
- Macros/templates that are safe to reuse with customers.
- Product docs for the features that generate the most tickets.
- Recent release notes that changed support workflows.
- Solved tickets that show repeatable resolutions.

Prefer documents with an owner, last-reviewed date, and clear source-of-truth status.

## What To Avoid

Do not include:

- Full workspace exports or entire drive dumps.
- Slack DMs, private channels, or private meeting notes.
- HR, legal, security secrets, credentials, tokens, or incident postmortems not approved for support use.
- Draft docs that contradict approved policy.
- Old versions of the same policy.
- Large piles of unreviewed ticket history.
- Customer-specific account data unless the customer explicitly approves it for the pilot.

## Folder Template

Ask the customer to organize files like this:

```text
customer_docs/
  01_policies/
  02_sops/
  03_macros/
  04_product_docs/
  05_solved_tickets/
  06_release_notes/
```

Use one folder per customer. Do not mix customer files with demo data or another customer's pilot corpus.

## Solved Ticket CSV Export

For v0, use CSV exports instead of live ticketing APIs.

Recommended export scope:

- Last 100 to 1000 solved tickets.
- Only ticket categories that match the pilot use case.
- Only tickets tagged with useful support categories.
- Remove unnecessary customer names, emails, contract details, and secrets.

Recommended columns:

```text
ticket_id,title,problem,resolution,tags,product_area,created_at,solved_at,source_url_optional
```

Each row should describe the support problem and the final resolution in plain language. Avoid raw transcript dumps when a concise problem/resolution export is available.

## Trusted And Current Labels

Ask the customer to label source-of-truth docs before upload:

- Add `Status: Current` or `Status: Deprecated` near the top of Markdown or text exports.
- Include `Owner`, `Last reviewed`, and `Audience` where possible.
- Put deprecated docs in a separate `do_not_upload/` folder.
- Choose one source of truth when two docs conflict.

Suggested filename convention:

```text
YYYY-MM-DD_owner_topic_status.ext
2026-05-01_support_refund_policy_current.md
```

## Define 20 Known Questions

Before the pilot starts, ask the customer for 20 real questions the support team expects the bot to answer.

Use this mix:

- 10 common policy or SOP questions.
- 5 troubleshooting questions.
- 3 customer-ready reply requests.
- 2 unsupported questions the bot should refuse.

For each question, ask the customer to identify the document that should support the answer. This becomes the initial quality benchmark.

## 30-Day Success Definition

A successful pilot does not require perfect answers. It should prove that curated docs reduce repeated questions.

Success means at least two of these are true after 30 days:

- 100 real support questions asked.
- 10 useful saved answers identified.
- 5 missing or outdated docs found and fixed.
- Support manager confirms fewer repeated questions in internal channels.
- Newer reps can answer common questions without asking a senior rep.
- The team agrees answer quality is good enough to continue with a paid deployment or connector roadmap.

## Internal Onboarding Checklist

- Confirm the customer understands v0 is manual upload plus optional CSV exports.
- Confirm written permission to use the provided docs for the pilot.
- Confirm the approved inference endpoint or private-GPU requirement.
- Store files in a customer-specific folder.
- Run `python scripts/prepare_docs.py --input customer_docs --output prepared_docs` if conversion or cleanup is needed.
- Upload only the prepared, approved docs.
- Paste the correct prompt pack.
- Run the customer's 20 known questions before opening access to the team.
