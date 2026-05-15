# SSO Escalation SOP

**Version**: 1.3  
**Last Updated**: 2026-01-10  
**Owner**: Customer Success Engineering  

## Purpose

This SOP outlines the process for triaging and escalating SSO provisioning and authentication issues.

## Severity Levels

### Severity 1 (Critical)
- **Impact**: Customer cannot access the application at all
- **Response time**: 1 hour
- **Escalation**: Immediate escalation to Engineering Support

### Severity 2 (High)
- **Impact**: Some users cannot authenticate, but workarounds exist
- **Response time**: 4 hours
- **Escalation**: Escalate if not resolved within 4 hours

### Severity 3 (Medium)
- **Impact**: SSO configuration issues, manual provisioning needed
- **Response time**: 24 hours
- **Escalation**: Optional, based on customer priority

## Common SSO Issues

### Issue 1: Users Cannot Log In via SSO

**Symptoms**:
- "Authentication failed" error
- Users redirected to error page
- SAML response errors in logs

**Triage steps**:
1. Verify SSO is enabled for the customer's account
2. Check if SSO metadata is up to date
3. Confirm user exists in identity provider
4. Review SAML assertion logs

**Resolution**:
- If metadata is stale: Request customer to re-upload metadata
- If user not provisioned: Guide customer through manual provisioning
- If assertion errors: Escalate to Engineering Support

### Issue 2: Group Sync Not Working

**Symptoms**:
- New users not receiving correct permissions
- Group mappings not reflecting in application
- Users missing from expected teams

**Triage steps**:
1. Verify group sync is enabled (Admin Settings > SSO > Group Sync)
2. Check last sync timestamp and status
3. Confirm group mappings match identity provider
4. Review sync logs for errors

**Resolution**:
- If sync is disabled: Enable and trigger manual sync
- If mappings are wrong: Update group mappings with customer
- If sync errors persist: Escalate to Engineering Support with logs

**Note**: Group sync behavior changed in v2.5.0 (see Release Notes for details)

### Issue 3: Just-in-Time Provisioning Failures

**Symptoms**:
- New users get "Access Denied" on first login
- Users created but without proper attributes
- Email/name fields not populating correctly

**Triage steps**:
1. Verify JIT provisioning is enabled
2. Check SAML assertion for required attributes
3. Confirm attribute mappings are correct
4. Review user creation logs

**Resolution**:
- If attributes missing: Work with customer to update identity provider
- If mappings incorrect: Update attribute mappings in Admin Settings
- If persistent failures: Escalate to Engineering Support

## Escalation Process

### When to Escalate to Engineering Support

**Escalate immediately if**:
- Severity 1 issue (complete access failure)
- Security-related SSO configuration problems
- SAML certificate expiration or trust issues
- Multiple customers affected (potential platform issue)

**Escalate after troubleshooting if**:
- Issue not resolved within SLA timeframe
- Root cause requires code changes or platform updates
- Customer is Enterprise tier or has escalated internally

### How to Escalate

1. Create Engineering Support ticket in Jira
2. Include:
   - Customer name and account ID
   - Severity level and business impact
   - Complete timeline of issue
   - All troubleshooting steps taken
   - Relevant logs and screenshots
   - Customer's identity provider type (Okta, Azure AD, etc.)
3. Notify in #engineering-support Slack channel
4. Set customer expectation: "I've escalated this to our Engineering team. They'll investigate and provide an update within [timeframe]."

## Customer-Safe Communication

### Initial Response Template

```
Thank you for reaching out about the SSO issue. I'm investigating this now and will 
have an update for you within [timeframe based on severity].

Could you please provide:
- The specific error message or screenshot
- Usernames or emails of affected users
- Whether this affects all users or specific individuals

I'll prioritize this and keep you updated.
```

### Escalation Notification Template

```
I've escalated this to our Engineering Support team for deeper investigation. 
They're reviewing the logs and will identify the root cause.

Expected timeline: [specific timeframe]

I'll keep you updated as soon as I hear back from the team.
```

## Related Documentation

- SSO Configuration Guide: `/docs/sso_setup.md`
- SAML Troubleshooting: `/docs/saml_troubleshooting.md`
- Release Notes (v2.5.0 Group Sync Changes): `/docs/release_notes.md`
- Engineering Support SLA: `/internal/engineering_sla.md`
