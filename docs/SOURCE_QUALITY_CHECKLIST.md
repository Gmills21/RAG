# Source Quality Checklist

Good retrieval starts with good source material. Use this checklist before uploading customer files into Kotaemon.

## Approved Docs Checklist

Upload a document only when all required items are true:

- [ ] The customer confirms it is approved for support-team use.
- [ ] The doc has a clear owner or responsible team.
- [ ] The doc is current enough for pilot decisions.
- [ ] The doc does not include secrets, credentials, or unrelated private data.
- [ ] The doc answers a real support, CS, onboarding, or operations question.
- [ ] The doc can be cited to a support rep without creating confusion.

Preferred doc types:

- Policies.
- SOPs and runbooks.
- Support macros and response templates.
- Product docs and help center exports.
- Release notes and known issue notes.
- Clean solved-ticket CSV exports.

## Outdated Docs Checklist

Do not upload documents that match any of these until the customer reviews them:

- [ ] Old policy versions.
- [ ] Draft pages that conflict with current docs.
- [ ] Docs without an owner or review date when the topic is sensitive.
- [ ] Meeting notes that mention future plans as if they are current.
- [ ] Release notes older than the pilot scope requires.
- [ ] Docs that use product names, pricing, or process steps that changed.

If a stale doc is useful for history, keep it in a separate `archive_do_not_upload/` folder.

## Duplicate Docs Checklist

Duplicates make answers weaker because retrieval may pull the wrong version. Before upload:

- [ ] Search for multiple files with the same topic.
- [ ] Keep the newest approved version.
- [ ] Remove exported copies with names like `final`, `final_v2`, or `old`.
- [ ] Merge useful content into the source-of-truth doc when needed.
- [ ] Confirm only one doc owns each policy or process.

Rule: **If two docs conflict, do not upload both until the customer chooses the current source of truth.**

## Sensitive Docs Warning

Do not upload:

- Passwords, API keys, tokens, certificates, or private keys.
- HR files, compensation data, performance reviews, or private personnel notes.
- Legal strategy, privileged communications, or contract redlines.
- Security incident details that are not approved for support use.
- Slack DMs, private channels, or whole workspace exports.
- Customer data that is not needed for the pilot.

When in doubt, exclude the document and ask the customer to approve a sanitized version.

## Minimum Viable Support Corpus

Recommended starting corpus:

- 10 to 30 SOPs/policies.
- 20 to 100 help-center or product docs.
- 50 to 500 solved tickets if available.
- 10 to 30 support macros/templates if available.

Smaller and cleaner is better than larger and noisy. Add documents only when they answer pilot questions.

## Naming Conventions

Use names that help humans inspect citations:

```text
01_refund_policy_current.md
02_sso_escalation_sop_current.md
03_billing_macros_current.csv
04_release_notes_2026_q2_current.md
```

Recommended pattern:

```text
area_topic_status.ext
```

Avoid vague names like:

- `doc1.pdf`
- `New policy final final.pdf`
- `Export 2026.zip`
- `Random notes.md`

## Recommended Metadata Fields

Add these fields near the top of Markdown/text exports when possible:

```text
Document type:
Owner:
Status:
Last reviewed:
Audience:
Source URL:
```

For CSV exports, include:

```text
ticket_id,title,problem,resolution,tags,product_area,created_at,solved_at,source_url_optional
```

## Pre-Pilot Cleanup Checklist

- [ ] Remove deprecated docs from the upload folder.
- [ ] Remove duplicate docs.
- [ ] Separate sensitive docs into `do_not_upload/`.
- [ ] Confirm all filenames are understandable.
- [ ] Confirm policies with approval thresholds are current.
- [ ] Confirm macros are approved customer-facing language.
- [ ] Confirm solved-ticket CSV rows are concise and sanitized.
- [ ] Run a quick manual read of the top 20 docs.
- [ ] Define 20 known pilot questions and expected source docs.
- [ ] Upload only the approved folder, not the entire workspace.
