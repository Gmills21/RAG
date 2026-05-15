# Manual Eval Sheet

Use this sheet when running `evals/support_eval_questions.jsonl` manually in Kotaemon. Copy it into a dated results file if you want to preserve each run.

| ID | Question | Expected behavior | Actual answer notes | Correct source cited? yes/no | Hallucinated? yes/no | Customer-ready reply usable? yes/no | Pass/fail |
|---|---|---|---|---|---|---|---|
| Q001 | Can we refund a monthly Growth customer 20 days after the charge? | Full refund within 30 days if no exception applies; cite refund policy. |  |  |  |  |  |
| Q002 | Can support refund an Annual Enterprise customer without approval? | No; Finance Director and assigned CSM approval required. |  |  |  |  |  |
| Q003 | Who approves a refund over $5,000? | Finance approval required. |  |  |  |  |  |
| Q004 | What should support do if the customer already filed a chargeback and asks for a refund? | Do not issue refund; route to Billing Disputes; use chargeback tag/macro. |  |  |  |  |  |
| Q005 | What tag should be used after processing an eligible refund? | `refund-processed`. |  |  |  |  |  |
| Q006 | Write a customer-ready reply for a failed invoice payment. | Uses failed invoice macro and 7-day grace window. |  |  |  |  |  |
| Q007 | What are the first triage steps for an SSO group sync issue? | Scope, config, manual sync, release note check, escalation. |  |  |  |  |  |
| Q008 | When should an SSO issue be escalated to Engineering Support? | Escalation conditions from SSO SOP. |  |  |  |  |  |
| Q009 | What severity applies if all SSO logins are failing for a customer? | Sev 1, 15 minute response target, Engineering Support on-call. |  |  |  |  |  |
| Q010 | What changed in release 2026.05 for SSO group sync? | Nested IdP group flattening by default. |  |  |  |  |  |
| Q011 | What changed in the billing clarity release? | Release 2026.04 billing changes. |  |  |  |  |  |
| Q012 | How should a new support rep use the bot during week 1? | Shadow mode flow from onboarding guide. |  |  |  |  |  |
| Q013 | What is the Berlin office lunch policy? | Refuse with `Not enough source support`. |  |  |  |  |  |
| Q014 | What is the usage-overage refund policy? | Refuse with `Not enough source support`. |  |  |  |  |  |
| Q015 | What is our SOC 2 Type II availability date? | Refuse with `Not enough source support`. |  |  |  |  |  |
| Q016 | Can we offer a 20 percent early renewal discount? | Refuse with `Not enough source support`. |  |  |  |  |  |
| Q017 | What is the password reset process for non-SSO accounts? | Refuse with `Not enough source support`. |  |  |  |  |  |
| Q018 | A customer asks for a refund after 45 days but says there was an outage. What should we do? | Ambiguous; need documented SLA outage before commitment. |  |  |  |  |  |
| Q019 | A customer says wrong people suddenly have access after the latest SSO release. Is that a bug? | Ambiguous; cite nested-group release behavior and mapping review. |  |  |  |  |  |
| Q020 | Which refund tag should I use? | Ambiguous; ask scenario or map tags by scenario. |  |  |  |  |  |
