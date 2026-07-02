# Threat model

This starter treats context mixing as the main risk.

## Risks

1. Work data copied into personal memory.
2. Personal data copied into work memory.
3. A profile takes action in the wrong account.
4. Email/ticket ingestion stores too much raw sensitive content.
5. A cron job runs with broader tools than intended.

## Controls

- Separate Hermes profiles: `personal`, `work`, `insights`.
- Separate memory folders.
- Read-only external integrations at first.
- Summaries instead of raw mailbox archives.
- Explicit refusal rules in each `SOUL.md`.
- Cron jobs scoped to a single profile.
- Static verification script for starter boundaries.

## Default action policy

The starter should only read and summarize.

Do not enable these until you have at least a week of clean read-only operation:

- Send email.
- Archive/delete email.
- Post Slack messages.
- Comment on tickets.
- Close or assign tickets.
- Edit calendar events.

## Data retention

Start by retaining summaries, not raw messages. If a summary needs evidence, store a stable source pointer such as a thread ID, ticket ID, or date range instead of copying full content.
