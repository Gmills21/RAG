# Product Release Notes

## Version 2.5.0 (January 15, 2026)

### New Features

**SSO Group Sync Improvements**
- Automated group membership synchronization from identity providers
- Support for nested groups in Azure AD and Okta
- Configurable sync frequency (hourly, daily, or manual)
- **Breaking change**: Group sync now requires explicit attribute mapping in Admin Settings

**Dashboard Widgets**
- Customizable dashboard with drag-and-drop widgets
- New analytics widgets for usage tracking
- Export dashboard data to CSV

**API Rate Limiting**
- Implemented fair-use rate limits: 1000 requests/hour per organization
- Rate limit headers included in all API responses
- Enterprise plans support custom rate limit increases

### Bug Fixes

- Fixed issue where SSO users couldn't update profile information
- Resolved data export timeout for large datasets
- Corrected timezone display in activity logs
- Fixed search results pagination for more than 1000 items

### Known Issues

- Group sync may take up to 1 hour for initial synchronization
- Safari users may experience slow dashboard loading with 10+ widgets
- API pagination limit is currently capped at 100 items per page

---

## Version 2.4.2 (December 10, 2025)

### Security Updates

**Critical Security Patch**
- Fixed authentication bypass vulnerability in SSO flow
- All customers should update immediately or verify automatic patch deployment
- No action required for cloud-hosted customers (auto-patched)

**Enhanced Session Management**
- Session timeout reduced to 12 hours (previously 24 hours)
- Concurrent session limit: 5 per user (Enterprise customers can request increase)
- Force logout all sessions option added to Admin Settings

### Improvements

- Faster page load times (30% improvement on dashboard)
- Improved error messages for API authentication failures
- Better mobile responsiveness for support ticket view

### Bug Fixes

- Fixed export function for tickets with large attachments
- Resolved issue with special characters in custom field names
- Corrected sorting behavior in user management table

---

## Version 2.4.0 (November 1, 2025)

### New Features

**Advanced Search**
- Boolean operators (AND, OR, NOT) in search queries
- Search within specific fields (title, description, tags)
- Saved search filters for quick access
- Search history with one-click recall

**Bulk Operations**
- Bulk assign tickets to users or teams
- Bulk tag updates for multiple tickets
- Bulk status changes with audit trail
- CSV import for bulk ticket creation

**Custom Notifications**
- Configurable notification rules per user
- Slack integration for real-time alerts (Beta)
- Email digest options: immediate, hourly, or daily
- Mute notifications for specific projects or tags

### Improvements

- Ticket creation form now auto-saves drafts
- Improved attachment preview for images and PDFs
- Faster search indexing (results appear in under 1 second)

### Bug Fixes

- Fixed issue with email notifications not respecting user preferences
- Resolved attachment upload failures for files over 25MB
- Corrected calculation of SLA breach times across time zones
