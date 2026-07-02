---
name: work-ticket-radar
description: Summarize important Linear/ClickUp ticket changes into Markdown without mutating tickets.
version: 1.0.0
platforms: [linux, macos]
metadata:
  hermes:
    tags: [work, tickets, radar, read-only]
    category: context-radar
    requires_toolsets: [file, skills]
---

# Work Ticket Radar

## When to use

Use on a schedule or on demand to understand what changed in the work ticket system since the last run.

## Required constraints

- Use only the configured work Linear/ClickUp workspace.
- Use read-only operations only: list/search/read.
- Do not create, comment, assign, close, prioritize, change status, or edit tickets.
- Store summaries only under `memory/work/**`.
- Do not store full raw ticket histories unless the user explicitly asks for a one-off capture.

## Procedure

1. Determine the current date as `YYYY-MM-DD`.
2. Find assigned, mentioned, subscribed, due-soon, blocked, urgent, or recently changed tickets.
3. Prioritize tickets where the user is directly responsible or blocked.
4. Write or update:
   - `memory/work/tickets/YYYY-MM-DD.md`
   - `memory/work/daily/YYYY-MM-DD.md`
5. Include ticket IDs and URLs/pointers where available.

## Output format

```md
# Work Ticket Radar — YYYY-MM-DD

## Assigned to me

- TICKET-ID — Title
  - Status: current status
  - Change: what changed since last run
  - Next suggested action: optional

## Waiting on me

- TICKET-ID — what is expected and by when

## Blocked / at risk

- TICKET-ID — blocker and likely owner

## Useful background

- Non-urgent changes that may matter later.
```

## Verification

Before finishing, check that no personal content was written and no ticket mutation occurred.
