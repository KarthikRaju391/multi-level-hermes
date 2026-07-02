# Safety policy

## Default stance

All integrations are read-only in the initial version. The agent may summarize, plan, and draft suggestions, but it must not mutate external systems.

## Allowed by default

- Read configured email/ticket/calendar sources.
- Summarize into the profile's own memory folder.
- Link to source pointers such as thread IDs or ticket IDs.
- Produce daily/weekly cross-context reflections from summaries.

## Denied by default

- Send email.
- Archive, delete, label, or move email.
- Post comments.
- Close, assign, prioritize, or edit tickets.
- Post Slack/Discord messages.
- Modify calendar events.
- Copy raw work content into personal memory.
- Copy raw personal content into work memory.

## Confirmation rule for future write access

If write tools are enabled later, require:

1. The active context.
2. The target account/system.
3. A preview of the exact change.
4. Explicit user confirmation.
