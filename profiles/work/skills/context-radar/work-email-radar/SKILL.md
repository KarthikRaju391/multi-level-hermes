---
name: work-email-radar
description: Summarize important work email changes into Markdown without taking actions.
version: 1.0.0
platforms: [linux, macos]
metadata:
  hermes:
    tags: [work, email, radar, read-only]
    category: context-radar
    requires_toolsets: [file, skills]
---

# Work Email Radar

## When to use

Use on a schedule or on demand to understand what changed in the work inbox since the last run.

## Required constraints

- Use only the configured **work** email account.
- Use read-only operations only: search/list/read.
- Do not send, archive, delete, relabel, move, unsubscribe, or mark messages.
- Do not read or summarize personal email.
- Store summaries only under `memory/work/**`.
- Do not store full raw email bodies unless the user explicitly asks for a one-off capture.

## Procedure

1. Determine the current date as `YYYY-MM-DD`.
2. Find new or changed work email threads since the last run.
3. Prioritize direct-to-me, cc-me, manager/lead/team/client messages, deadlines, blockers, escalations, incident/customer-impact language, and ticket/project mentions.
4. Ignore newsletters, automated notifications, and no-reply noise unless they indicate a real blocker or incident.
5. Write or update:
   - `memory/work/inbox/YYYY-MM-DD.md`
   - `memory/work/daily/YYYY-MM-DD.md`
6. Include source pointers, not raw message dumps.

## Output format

```md
# Work Email Radar — YYYY-MM-DD

## High-priority changes

### Short title
- Source: sender/date/thread pointer
- Related: ticket/project if known
- Summary: one or two sentences
- Suggested action: optional
- Confidence: high | medium | low

## Waiting on me

- Person/team is waiting for X by Y.

## Useful background

- Relevant non-urgent context.

## Ignored / low signal

- Categories skipped and why.
```

## Verification

Before finishing, check that no personal content was written and no external action was taken.
