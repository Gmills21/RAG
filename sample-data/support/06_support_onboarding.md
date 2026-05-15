# Support Rep Onboarding — Using the Knowledge Bot

**Document type:** Internal onboarding guide
**Owner:** Support Enablement
**Status:** Current — source of truth for new support reps
**Audience:** New support reps in week 1 to week 4

This document is fictional sample data for the Support Knowledge Bot
demo. It does not describe a real onboarding program.

---

## 1. What the knowledge bot is

The Support Knowledge Bot is an internal assistant that reads our
approved support documents and answers questions from your team. It is
**not** a replacement for your judgment. It is a faster way to find
the right SOP, policy, release note, or solved ticket so you can apply
it.

The bot returns six things for every answer it can support:

1. An **internal answer** for you.
2. A **customer-ready reply** you can adapt before sending.
3. The **sources used** (file names, sections).
4. A **confidence** rating: High / Medium / Low.
5. **Escalate if** conditions.
6. A **suggested tag or macro** when one applies.

If it cannot find enough source support, it will say so explicitly
("Not enough source support"). That is the correct behavior. It is
better for the bot to refuse than to invent policy.

## 2. How to use the bot in week 1

In your first week, use the bot in **shadow mode**:

1. Pick a ticket from your queue.
2. Read the ticket yourself first. Form your own draft answer.
3. Ask the bot the same question.
4. Compare. Where does the bot's answer differ from yours? Why?
5. Open the cited source documents and read them yourself.
6. Send a final reply that you (the human) own.

The goal of week 1 is not speed. The goal is to learn which questions
the bot answers well, which it gets wrong, and which sources you
should already know by heart.

## 3. The citation rule (this is the most important rule)

> **Only trust an answer when citations are present and the cited
> source actually says what the bot claims.**

This means:

- If the bot's answer has **no citations**, do not use it as a
  customer reply. Treat it as a guess.
- If the bot's answer has citations, **open the cited file** and
  confirm the cited text matches the claim. The bot can sometimes
  cite the right file but summarize the wrong section.
- If the cited source actually disagrees with the bot's claim, do
  **not** send the answer. Use the source. Flag the discrepancy in
  `#support-bot-feedback` so the prompt or docs can be improved.
- If the bot says "Not enough source support," that is a signal that
  this question needs either a human answer, a docs update, or
  manager input. Treat the refusal as useful information, not a
  failure.

## 4. When the bot is most reliable

Based on the sample corpus and similar deployments, the bot is most
reliable for:

- Refund policy questions where the policy file directly applies
  (within 30 days, exceptions list, approval thresholds).
- SSO triage steps where the SOP file directly applies.
- "What changed in the latest release?" questions.
- Routine billing macros (when to use which macro).

## 5. When the bot is least reliable

The bot is least reliable for:

- Questions about pricing, contracts, or commercial terms that are
  not in the uploaded docs.
- Questions about a customer's *specific* account configuration (the
  bot cannot see the customer's data).
- Questions about features that shipped after the latest release note
  in this corpus.
- Edge cases that combine two policies (for example, "annual
  enterprise customer with a chargeback") — these almost always need
  a team lead.

When in doubt, escalate to a team lead rather than guessing.

## 6. How to phrase a question

Good questions to the bot:

- "Can we refund a customer 20 days after the charge?"
- "What are the SSO group sync escalation steps for a Sev 2?"
- "What changed in the latest SSO release?"
- "Write a customer-ready reply for a failed invoice payment."

Less effective questions:

- "Help" (too vague — the bot has no context).
- "Should I refund this customer?" (the bot has no view of the
  customer's account).
- "What does my manager think about this?" (the bot only knows what
  is in the uploaded docs).

If the bot's answer is off, try re-asking with more specific language
from the policy you suspect applies. For example, "30 days," "annual
enterprise contract," "chargeback in progress."

## 7. Feedback loop

If the bot is wrong, or refuses where the docs do contain the answer,
post in `#support-bot-feedback` with:

1. The exact question you asked.
2. The bot's answer (paste it).
3. What you expected, and why.
4. Which file(s) you think should have been cited.

The Support Enablement team reviews this channel weekly and updates
the source documents or the prompt template as needed.

## 8. What we do NOT use the bot for

- Sending replies directly from the bot to the customer. A human
  always sends the final reply.
- Replacing the manager / lead review on Sev 1 and Sev 2 tickets.
- Replacing the source documents themselves. If a policy is
  ambiguous, fix the policy doc, do not work around it in the bot.
- Refund or billing decisions over the rep's approval limit. The bot
  can describe the policy; it cannot approve the refund.
