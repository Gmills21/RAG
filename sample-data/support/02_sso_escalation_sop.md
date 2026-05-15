# SSO Provisioning Issue Triage SOP

**Document type:** Internal SOP
**Owner:** Support Team — Identity & Access
**Status:** Current — source of truth
**Last reviewed:** 2026-04-12
**Audience:** Support reps, Support team leads, Engineering Support

This document is fictional sample data for the Support Knowledge Bot
demo. It does not describe a real product.

---

## 1. When to use this SOP

Use this SOP any time a customer reports any of the following:

- A new user cannot log in after the customer added them to the IdP
  (Okta, Azure AD / Entra ID, Google Workspace, JumpCloud).
- A user's group membership in our product does not match their group
  membership in the IdP.
- Users disappear from a group after a sync.
- Just-in-time (JIT) provisioning is creating users with the wrong
  role.
- SCIM endpoint is returning 4xx / 5xx errors to the IdP.

Out of scope for this SOP:

- Password reset for non-SSO accounts (see general account SOP).
- SAML certificate rotation (see security runbook).

## 2. Severity levels

| Severity | Definition | Initial response target | Owner |
|---|---|---|---|
| **Sev 1** | All SSO logins failing for a customer; production-down for that tenant | 15 minutes | Engineering Support on-call |
| **Sev 2** | Some users cannot log in OR group sync wrong for >5 users | 1 hour | Support rep with Engineering Support backup |
| **Sev 3** | Single user cannot log in / single group out of sync | 4 hours | Support rep |
| **Sev 4** | Configuration question, no current outage | Next business day | Support rep |

If the customer has an Annual Enterprise contract, bump the assigned
severity up by one level (Sev 3 becomes Sev 2, etc.).

## 3. Triage steps

Run these steps **in order** before escalating.

### Step 1 — Confirm scope

Ask the customer:

1. Is this affecting one user, many users, or every user?
2. When did the customer first notice the issue?
3. What changed on their side recently? (New IdP, new group, removed
   group, role mapping change, SCIM token rotation.)
4. What error message is the user seeing?

Tag the ticket with `sso` and one of `sso-single-user`,
`sso-some-users`, or `sso-all-users`.

### Step 2 — Verify configuration in the admin panel

In the internal admin tool, open the customer's tenant:

1. Confirm the SSO connection status is `active` (not `pending` or
   `error`).
2. Confirm the SCIM endpoint last successful sync timestamp is within
   the last 24 hours. If it is older, that is your likely cause.
3. Confirm the group mapping table is populated and that the customer's
   internal group names map to our product roles.

### Step 3 — Re-run a manual sync

From the admin tool, click **Trigger SCIM sync now** for the
customer's tenant. Wait 60 seconds and refresh.

- If the sync now succeeds and the affected user(s) appear with the
  correct group / role, resolve the ticket and add tag
  `sso-resolved-by-manual-sync`.
- If the sync still fails, capture the error message and the SCIM
  request ID from the sync log and proceed to Step 4.

### Step 4 — Check the release notes

Open `04_release_notes.md`. Specifically check whether a recent release
changed SSO group sync behavior. If yes, the issue is likely caused by
that change and the customer may need to re-map groups. Communicate
this clearly and link the relevant release note in the customer reply.

### Step 5 — Escalate to Engineering Support

Escalate to **Engineering Support** (channel `#eng-support-on-call`,
or page the on-call rotation for Sev 1/Sev 2) if any of the following
are true:

- The connection status shows `error` and Step 3 did not resolve it.
- SCIM is returning 5xx errors.
- The sync log shows our service is rejecting valid IdP payloads.
- Multiple customers are reporting the same SSO issue at once
  (potential platform-wide incident — escalate immediately as Sev 1
  regardless of per-customer scope).

Provide Engineering Support with:

- Customer / tenant ID.
- Affected user IDs.
- Sync log error message and SCIM request ID from Step 3.
- Timeline of when the customer first noticed.
- What changed on the customer's IdP side (from Step 1).
- Whether the customer is on an Annual Enterprise contract.

## 4. Customer-safe wording

Do not expose internal diagnostics, tenant IDs, or SCIM request IDs in
customer-facing replies.

**Initial acknowledgement (any severity):**

> "Thanks for the details. I'm looking into the SSO sync for your
> team now. I'll confirm what we're seeing on our side and follow up
> shortly with next steps."

**If a manual sync resolved it (Step 3):**

> "I re-ran the sync for your account and the affected user(s) are
> now showing the correct group and access. Please ask them to sign
> out and back in once. Let me know if anything still looks off."

**If a recent release changed group-sync behavior (Step 4):**

> "We made an update to how group sync handles nested IdP groups in a
> recent release. Some customers need to remap their groups after that
> change. Here's the relevant release note and the steps to remap.
> Happy to walk through it on a call if that's easier."

**If we need to escalate to Engineering Support:**

> "I've handed this to our engineering support team so we can look
> into it more deeply. We'll follow up within [response target] with
> an update. In the meantime, here's a workaround you can use:
> [if applicable]."

Never say "our system is broken," "this is a bug on our side," or
commit to a fix ETA in writing before Engineering Support confirms.

## 5. When NOT to escalate

Resolve at the support tier (do not escalate to Engineering Support)
if any of these apply:

- The customer's IdP group name does not match anything in the
  mapping table; that's a customer configuration issue — guide them
  through the admin UI.
- The user logging in has not yet been added to any IdP group at all;
  that's also customer-side.
- The user is hitting MFA challenges, not SSO failures (different SOP).

## 6. Tags to use

- `sso` — always.
- `sso-single-user` / `sso-some-users` / `sso-all-users` — scope.
- `sso-group-sync` — if the issue is specifically group mapping.
- `sso-resolved-by-manual-sync` — Step 3 succeeded.
- `sso-engineering-support` — escalated to Engineering Support.
- `sso-customer-config` — root cause was customer-side IdP config.
- `enterprise` — Annual Enterprise contract.
