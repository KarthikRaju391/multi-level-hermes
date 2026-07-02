---
name: personal-email-radar
description: Summarize important personal email changes into Markdown without taking actions.
version: 1.0.0
platforms: [linux, macos]
metadata:
  hermes:
    tags: [personal, email, radar, read-only]
    category: context-radar
    requires_toolsets: [file, skills]
---

# Personal Email Radar

## When to use

Use on a schedule or on demand to understand what changed across the configured personal inboxes since the last run.

## Required constraints

- Use only the configured **personal** email accounts.
- Treat each personal mailbox as a separate source. Keep source pointers account-scoped.
- Use read-only operations only: search/list/read.
- Do not send, archive, delete, relabel, move, unsubscribe, or mark messages.
- Do not read or summarize work email.
- Store summaries only under `memory/personal/**`.
- Do not store full raw email bodies unless the user explicitly asks for a one-off capture.

## Procedure

1. Determine the current date as `YYYY-MM-DD`.
2. Find configured personal email accounts from local account config.
3. For each personal account, find new or changed personal email threads since the last run.
4. Prioritize direct-to-me, important, time-sensitive, travel, bills, appointments, family/friends, and personal project threads.
5. Keep account labels in every source pointer, for example `personal_primary:thread-id`.
6. Ignore promotions, newsletters, social updates, and automated noise unless explicitly important.
7. Write or update:
   - `memory/personal/inbox/YYYY-MM-DD.md`
   - `memory/personal/daily/YYYY-MM-DD.md`
8. Include source pointers, not raw message dumps.

## Output format

```md
# Personal Email Radar — YYYY-MM-DD

## Needs attention

### Short title
- Source: account/sender/date/thread pointer
- Summary: one or two sentences
- Suggested action: optional
- Confidence: high | medium | low

## Useful context

- Bullet summaries of non-urgent context.

## Ignored / low signal

- Categories skipped and why.
```

## Verification

Before finishing, check that no work-related content was written and no external action was taken.
