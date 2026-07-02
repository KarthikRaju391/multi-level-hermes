# Architecture

The starter keeps the first version intentionally simple:

1. **Hermes profiles define behavioral boundaries.**
2. **Read-only radar jobs create Markdown summaries.**
3. **The insights profile reads summaries from both sides.**
4. **No profile can take destructive external actions by default.**

## Contexts

### Personal

Owns personal planning, personal projects, and personal account summaries.

Allowed memory writes:

- `memory/personal/**`

Not allowed:

- Work email, work tickets, work repos, work docs, work Slack.

### Work

Owns work planning, work projects, work email summaries, and work ticket summaries.

Allowed memory writes:

- `memory/work/**`

Not allowed:

- Personal email, personal calendar, personal projects, personal notes.

### Insights

Owns cross-context reflection.

Allowed reads:

- `memory/personal/daily/**`
- `memory/personal/inbox/**`
- `memory/work/daily/**`
- `memory/work/inbox/**`
- `memory/work/tickets/**`

Allowed writes:

- `memory/insights/**`

Not allowed:

- Sending messages.
- Modifying tickets.
- Moving calendar events.
- Copying raw sensitive content between personal and work memory.

## Data flow

```diagram
╭──────────────────────╮
│ Personal email       │
│ read-only integration│
╰──────────┬───────────╯
           ▼
╭──────────────────────╮       ╭──────────────────────╮
│ personal-email-radar │──────▶│ memory/personal      │
│ summarize only       │       │ inbox + daily notes   │
╰──────────────────────╯       ╰──────────┬───────────╯
                                           │
                                           ▼
                                   ╭──────────────╮
                                   │ insights     │
                                   │ daily review │
                                   ╰──────────────╯
                                           ▲
                                           │
╭──────────────────────╮       ╭──────────┴───────────╮
│ work email/tickets   │       │ memory/work          │
│ read-only integrations│─────▶│ inbox + tickets      │
╰──────────────────────╯       ╰──────────────────────╯
```

## Why not GBrain yet?

This phase is for validating the safety model and discovering what summaries are useful. Add GBrain only after Markdown summaries become hard to search or the history is large enough to justify entity linking and semantic retrieval.
