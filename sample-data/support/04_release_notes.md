# Release Notes

**Document type:** Customer-facing release notes (internal copy)
**Owner:** Product Operations
**Status:** Current — source of truth for support discussions
**Audience:** Support, CS, customers

This document is fictional sample data for the Support Knowledge Bot
demo. It does not describe real product changes.

The three most recent releases are documented below, newest first.

---

## Release 2026.05 — "Nested groups" (released 2026-05-02)

### Highlights

- **SSO group sync now flattens nested IdP groups by default.**
- New in-app comment thread on dashboards.
- Improved CSV export performance on large reports.

### SSO group sync — IMPORTANT change

Before this release, group sync **only** considered direct membership
in the IdP group that was mapped to a product role. If your IdP used
nested groups (a parent group containing child groups), users who were
members of only a child group did **not** receive the role.

Starting with this release, group sync **flattens nested IdP groups**
when evaluating membership. A user who is a member of any group nested
inside a mapped IdP group will now receive the corresponding product
role.

### What customers should do after this release

1. Review the **Group mappings** table in **Admin → SSO → Groups**.
2. If your IdP uses nested groups, expect a wider set of users to be
   assigned roles than before. This is the intended behavior.
3. If you do **not** want a nested group's members to receive a role,
   move the affected child group out of the mapped parent in your IdP,
   or remove the mapping entirely.
4. After making changes, click **Trigger SCIM sync now** in the admin
   panel and wait one minute for the sync to settle.

Customers reporting that "the wrong people suddenly have access" or
"a group now contains users that were never in it before" are almost
always seeing this release's behavior. Direct them here and to
`02_sso_escalation_sop.md` Step 4.

### Known follow-ups

- We are tracking an enhancement to surface a preview of "who would be
  affected" before this change applies, to be considered for a later
  release.

---

## Release 2026.04 — "Billing clarity" (released 2026-04-08)

### Highlights

- Invoice line items now show the time period covered.
- New "Payment failed" email template with a direct retry link
  (referenced by macro `failed_invoice_payment_retry`).
- Refund receipts are now sent automatically when a refund is
  processed through the billing dashboard.
- Self-serve customers can now download a billing history CSV from
  **Settings → Billing → History**.

### Customer impact

No action required. The new emails replace the previous "Payment
declined" template automatically.

### Known follow-ups

- A customer-visible refund status (Pending → Processed) page is
  on the roadmap but not in this release.

---

## Release 2026.03 — "Inbox cleanups" (released 2026-03-14)

### Highlights

- Bulk-archive support in the Inbox view.
- New keyboard shortcut `g i` to jump to Inbox from anywhere.
- Bug fix: emoji reactions on long threads no longer cause the
  reaction picker to render off-screen.

### Customer impact

No action required.

### Known follow-ups

- The Inbox virtualization work continues in 2026.05 to improve scroll
  performance on accounts with more than 10,000 items.

---

## Reference: how to use this file in the Support Knowledge Bot demo

The Support Knowledge Bot is expected to:

- Cite **release 2026.05** when answering questions about SSO group
  sync changes.
- Cite **release 2026.04** when answering questions about failed
  invoice payments or refund receipts.
- Say "Not enough source support" if asked about a release that is not
  in this file (for example, anything older than 2026.03 or anything
  in 2026.06+).
