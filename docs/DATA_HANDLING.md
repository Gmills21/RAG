# Data Handling Guide

This is operational guidance for founder-led demos and first pilots. It is not
legal advice. When a customer has legal, security, or compliance requirements,
get written approval from the customer and follow their process.

## Core Rule

Use only the smallest approved source set needed to test the support workflow.
Do not ingest everything.

## Inference Data Flow

The clean path is:

- Personal testing uses `dev-ollama` on the founder machine.
- Prospect demos use `demo-hosted`.
- Paid pilots use `pilot-hosted` by default.
- Private GPU is an exception when hosted inference is not allowed.

For `demo-hosted` and `pilot-hosted`, the app sends the user's question and the
retrieved source chunks to the configured hosted inference endpoint. Do not send
full workspace exports, unapproved files, or unrelated customer data. Record the
approved endpoint and data-flow note before the pilot starts.

## Demos

- Use fake data for demos.
- Use `sample-data/support/` for the standard demo.
- Do not mix real customer files into the demo corpus.
- Do not show one customer's data to another customer.
- Reset local data before switching from a customer pilot back to a public demo.

## Customer Pilots

For customer pilots, use only approved docs:

- Current SOPs and policies.
- Approved support macros.
- Help-center or product docs.
- Release notes relevant to support.
- Optional solved-ticket CSV exports approved for the pilot.

Do not request full workspace exports. Do not ask for broad access to Google
Drive, Slack, Jira, Zendesk, Confluence, or any other workspace system for v0.

## Data To Avoid

Do not request or upload:

- Slack DMs or private channels.
- HR files, personnel notes, compensation data, or performance reviews.
- Legal strategy, privileged material, or contract redlines.
- Secrets, credentials, API keys, tokens, certificates, or private keys.
- Security incident material not approved for support use.
- Whole mailbox, drive, workspace, or ticket-system exports.
- Customer account data that is not needed for the pilot.

When in doubt, exclude the file and ask the customer for a sanitized version.

## Customer Separation

Keep each customer in a separate local instance, dedicated single-customer VPS,
or clearly separated app data folder.

Recommended folder naming:

```text
customer_docs/acme_2026_pilot/
prepared_docs/acme_2026_pilot/
pilot_records/acme_2026_pilot/
```

For first real pilots, prefer one dedicated single-customer VPS per customer.
Do not mix multiple customer datasets in the same demo, collection, app data
folder, or VPS.

## Access And Exposure

- Do not expose raw port 7860 publicly during customer pilots.
- Use HTTPS through a reverse proxy for VPS pilots.
- Use strong access control before inviting customer users.
- Use the production inference profile approved for that customer.
- Keep `.env` files, keys, and customer data out of git.
- Share access only with the named pilot team.

## Approved Docs Workflow

1. Send `docs/CUSTOMER_ONBOARDING.md`.
2. Ask the customer to provide only approved docs.
3. Run `docs/SOURCE_QUALITY_CHECKLIST.md`.
4. Prepare files with `scripts/prepare_docs.py` if useful.
5. Upload only the approved prepared folder.
6. Configure the approved inference profile.
7. Record the customer-specific known questions and expected sources.

## Deletion And Retention

- Delete pilot data after the pilot if the customer requests it.
- Confirm deletion in writing after the reset is complete.
- Keep only non-sensitive pilot notes needed for the commercial record.
- Do not keep customer docs in demo folders after the pilot.

Use `scripts/reset_local_data.sh` only when you intend to delete and recreate
the local Kotaemon app data folder for that instance.

## Recommended Written Permission Note

Send a short approval note before receiving or uploading customer files:

```text
Please confirm that the files you provide for this pilot are approved for use in a private support knowledge-base test. We will use only these approved docs and optional CSV exports for the pilot. We will not request full workspace access, Slack DMs/private channels, HR/legal files, secrets, or credentials. The app may send your question and retrieved excerpts from approved docs to the configured inference endpoint so it can generate answers. We will keep this pilot data separate from other customer and demo data, and we will delete the pilot data after the pilot if you request it.
```

## Pre-Upload Checklist

- [ ] Customer approved the docs for pilot use.
- [ ] No full workspace export is included.
- [ ] No Slack DMs or private channels are included.
- [ ] No HR, legal, secrets, or credentials are included.
- [ ] Files are in a customer-specific folder.
- [ ] Demo data and other customer data are not present.
- [ ] Source docs are current or clearly labeled.
- [ ] The inference endpoint and data flow are approved.
- [ ] The pilot team and access method are defined.
