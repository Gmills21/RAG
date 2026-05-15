# Refund Policy

**Document type:** Internal policy
**Owner:** Finance Operations
**Status:** Current — source of truth
**Last reviewed:** 2026-04-01
**Audience:** Support, CS, Finance

This document is fictional sample data for the Support Knowledge Bot
demo. It does not describe any real company's policy.

---

## 1. Standard refund window

We offer a **full refund within 30 days** of the original charge for
all monthly self-serve plans (Starter, Growth, Pro). The 30-day clock
starts on the date the charge was successfully captured, not the date
of signup.

After day 30, the standard refund window is closed. Support may
**still process a pro-rated refund** for the unused portion of the
current monthly billing cycle if any of the following are true:

- The customer experienced a documented platform outage during the
  cycle that exceeded our SLA.
- The customer was charged after a confirmed downgrade or cancellation
  (billing error on our side).
- The customer is requesting because of a recent feature regression
  filed under a known-issue ticket.

For all other post-30-day requests, the default answer is **no refund**.
Support should offer service credit or a one-month discount instead.

## 2. Exceptions — when standard refund rules do NOT apply

The 30-day refund window **does not apply** to:

1. **Annual Enterprise contracts.** Refunds on Annual Enterprise
   contracts require an explicit signed amendment and Finance Director
   approval. Support cannot grant these refunds. Always escalate to
   the Customer Success Manager assigned to that account.
2. **Chargebacks.** If the customer has already filed a chargeback
   with their card issuer, do **not** issue any refund from our side.
   The dispute process owns the outcome. Hand the ticket to the
   Billing Disputes queue and add the tag `chargeback-in-progress`.
3. **Suspected fraud.** If the account is flagged for suspected fraud
   (multiple failed cards, mismatched billing identity, abuse signals),
   do **not** refund. Escalate to Trust & Safety. Do not confirm or
   deny the fraud flag in customer-facing wording.

## 3. Approval requirements

| Refund amount | Who can approve |
|---|---|
| Up to $500 | Support rep, no extra approval |
| $500 to $5,000 | Support team lead |
| **Over $5,000** | **Finance approval is required** (any invoice or refund over $5,000 must be reviewed by Finance before processing) |
| Annual Enterprise contract | Finance Director + assigned CSM |

The $5,000 threshold also applies to **invoice refunds**: any invoice
refund over $5,000 — regardless of plan type — requires Finance
approval before it is processed.

## 4. Process

1. Verify the customer's identity against the account email on file.
2. Confirm the charge date and amount in the billing dashboard.
3. Check the exception list above. If any exception applies, do not
   process the refund yourself; route the ticket per the table.
4. If the amount is within your approval limit, process the refund
   through the billing dashboard and add the tag `refund-processed`.
5. If the amount exceeds your approval limit, route to the named
   approver and tag `refund-pending-approval`.
6. Send the customer-facing reply (see macros in
   `03_billing_macros.csv`).
7. Note the resolution and the approving party in the ticket.

## 5. Customer-facing language

Support reps should never quote the internal exception list verbatim
to a customer. Use neutral, calm wording:

> "Thanks for reaching out. I've reviewed the charge on your account.
> Based on our refund policy, I'm able to process a [full / pro-rated]
> refund of $X for the [month / period] you described. You'll see it
> back on your card within 5–10 business days."

If the request is outside policy:

> "Thanks for reaching out. After reviewing your account, this charge
> falls outside our standard refund window. I'd love to offer service
> credit or a discount on your next month instead — would that work?"

For chargebacks already in progress:

> "I see your bank is reviewing a dispute on this charge. While that
> review is in progress, we're not able to issue a separate refund.
> Once the dispute is resolved, we can revisit if needed."

## 6. When to escalate

Escalate to a team lead or manager if any of the following are true:

- The amount exceeds your approval limit.
- The account is on an Annual Enterprise contract.
- The customer has filed (or threatens) a chargeback.
- The account is flagged for suspected fraud.
- The customer escalated to legal or to public social media.

## 7. Out of scope of this document

- Refunds for usage overage billing (see `usage_overage_policy.md`,
  not included in this demo corpus).
- Tax refunds (handled by Finance directly).
- Partner / reseller refunds (handled by Partnerships).
