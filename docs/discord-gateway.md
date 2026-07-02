# Discord gateway setup

Use Discord as the communication layer, not the source of truth. Hermes should write durable context to Markdown memory first, then post short notifications or answers back to Discord.

## Recommended shape

Create one private Discord server, for example `Hermes Command`, with separate categories for personal, work, insights, and ops.

Use **three Discord bot applications** if your Hermes deployment can run one gateway per profile:

- `Hermes Personal`
- `Hermes Work`
- `Hermes Insights`

This is slightly more setup than one bot, but it gives a clearer safety boundary: each bot can only see the channels for its profile.

```diagram
╭──────────────────────╮
│ Discord server        │
│ Hermes Command        │
╰──────┬────────┬───────╯
       │        │
       ▼        ▼
╭────────────╮  ╭────────────╮
│ Personal   │  │ Work       │
│ bot        │  │ bot        │
╰─────┬──────╯  ╰─────┬──────╯
      │               │
      ▼               ▼
memory/personal   memory/work
      │               │
      ╰───────┬───────╯
              ▼
       ╭────────────╮
       │ Insights   │
       │ bot        │
       ╰─────┬──────╯
             ▼
      memory/insights
```

## Channel layout

```text
Hermes Command
├── 00-router
│   └── #route-to-profile
├── personal
│   ├── #personal-chat
│   ├── #personal-radar
│   └── #personal-daily
├── work
│   ├── #work-chat
│   ├── #work-radar
│   ├── #work-tickets
│   └── #work-approvals
├── insights
│   ├── #daily-review
│   ├── #weekly-review
│   └── #patterns
└── ops
    ├── #gateway-status
    ├── #cron-log
    └── #boundary-alerts
```

## Permission matrix

| Bot | Can read/write | Should not see |
| --- | --- | --- |
| `Hermes Personal` | `#personal-chat`, `#personal-radar`, `#personal-daily` | work channels |
| `Hermes Work` | `#work-chat`, `#work-radar`, `#work-tickets`, `#work-approvals` | personal channels |
| `Hermes Insights` | insights channels, plus summary-only personal/work radar channels if needed | raw personal/work chat channels |

Keep bot permissions minimal:

- View Channel
- Send Messages
- Read Message History
- Use Application Commands
- Attach Files, optional

Do not grant by default:

- Administrator
- Manage Channels
- Manage Webhooks
- Manage Messages
- Mention Everyone

## Routing rules

Preferred routing is explicit:

- Mention `@Hermes Personal` in personal channels.
- Mention `@Hermes Work` in work channels.
- Mention `@Hermes Insights` in insights channels.

If you use `#route-to-profile`, require prefixes:

```text
p: plan my personal writing project
w: summarize my current ticket load
i: what affected my focus today?
```

Ambiguous write/action requests should not be routed automatically. The bot should ask which profile owns the request.

## Radar job output policy

Radar jobs should write full summaries to Markdown first:

- `memory/personal/inbox/YYYY-MM-DD.md`
- `memory/work/inbox/YYYY-MM-DD.md`
- `memory/work/tickets/YYYY-MM-DD.md`
- `memory/insights/daily-review/YYYY-MM-DD.md`

Discord messages should be short status updates, for example:

```text
Work radar updated: 3 high-priority changes, 2 waiting-on-me items, 1 ticket at risk.
Source: memory/work/inbox/2026-07-02.md
```

Do not post raw email bodies, raw ticket histories, or sensitive personal/work details into Discord unless you explicitly choose that tradeoff.

## Work confidentiality note

Only route work summaries through Discord if your work policy allows it. If work data should not leave approved systems, keep `#work-radar` messages generic and store details only in your local/private memory files.

## One-bot fallback

If your Hermes deployment only supports one Discord gateway bot, use one bot named `Hermes Router` and enforce channel-to-profile routing in config.

The fallback is simpler but weaker: the bot account can technically see all allowed channels, so the safety boundary depends more on software routing. Prefer three bots when possible.

## Setup sequence

1. Create the private Discord server.
2. Create categories and channels from the layout above.
3. Create one Discord application/bot per profile.
4. Invite each bot only to the channels it needs.
5. Store bot tokens and channel IDs in local config or Hermes profile secrets, never in git.
6. Run one Hermes gateway process per profile, each with its profile-specific token.
7. Send test prompts:
   - Personal bot: “Show me work radar.” Expected: refuse.
   - Work bot: “Summarize personal inbox.” Expected: refuse.
   - Insights bot: “What affected focus today?” Expected: read summaries only.
