---
name: daily-cross-context-review
description: Produce a daily review from personal and work Markdown summaries without taking actions.
version: 1.0.0
platforms: [linux, macos]
metadata:
  hermes:
    tags: [insights, review, personal, work]
    category: review
    requires_toolsets: [file, skills]
---

# Daily Cross-Context Review

## When to use

Use at the end of the day, or on demand, to understand what happened across personal and work contexts.

## Required constraints

- Read only Markdown summaries from `memory/personal/**` and `memory/work/**`.
- Write only to `memory/insights/**`.
- Do not access raw personal/work accounts by default.
- Do not take external actions.
- Do not copy raw sensitive work content into personal memory or raw personal content into work memory.

## Procedure

1. Determine the current date as `YYYY-MM-DD`.
2. Read today's personal summaries, work email summaries, and work ticket summaries if they exist.
3. Identify:
   - important changes
   - waiting-on-me items
   - blockers or risks
   - cross-context effects on focus/energy/progress
   - carry-over items for tomorrow
4. Write `memory/insights/daily-review/YYYY-MM-DD.md`.

## Output format

```md
# Daily Review — YYYY-MM-DD

## What changed

- Work: ...
- Personal: ...

## What affected focus or progress

- Cause: ...
- Evidence: cite summary file/date/section
- Effect: ...

## Waiting on me

- Work: ...
- Personal: ...

## Tomorrow's suggested plan

1. ...
2. ...
3. ...

## Uncertainties

- ...
```

## Verification

Before finishing, confirm no external action was taken and the output was written only under `memory/insights/**`.
