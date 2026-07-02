# Discord gateway setup

Use Discord as the communication layer, not the source of truth. Hermes should write durable context to Markdown memory first, then post short notifications or answers back to Discord.

## Recommended shape

Create **one private Discord server** and **one Discord bot** named `Hermes`.

The bot is a gateway/router. It is not one blended profile. When you tag `@Hermes`, the gateway chooses the correct Hermes profile based on the channel or an explicit prefix:

- personal channels route to the `personal` Hermes profile
- work channels route to the `work` Hermes profile
- insights channels route to the `insights` Hermes profile

```diagram
╭──────────────────────╮
│ Discord server        │
│ Hermes Command        │
╰──────────┬───────────╯
           ▼
╭──────────────────────╮
│ @Hermes bot           │
│ channel/profile router│
╰──────┬───────┬───────╯
       │       │
       ▼       ▼
╭──────────╮  ╭──────────╮
│ personal │  │ work     │
│ profile  │  │ profile  │
╰────┬─────╯  ╰────┬─────╯
     │             │
     ▼             ▼
memory/personal  memory/work
     │             │
     ╰──────┬──────╯
            ▼
      ╭──────────╮
      │ insights │
      │ profile  │
      ╰────┬─────╯
           ▼
    memory/insights
```

This is the simplest daily-use setup: one bot to tag, but still separate Hermes profiles behind it.

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

## Routing rules

Preferred routing is channel-based:

| Channel | Routed profile | Example |
| --- | --- | --- |
| `#personal-chat` | `personal` | `@Hermes help me plan this side project` |
| `#personal-radar` | `personal` | `@Hermes summarize personal email radar` |
| `#work-chat` | `work` | `@Hermes help me plan this ticket` |
| `#work-radar` | `work` | `@Hermes what changed in work email?` |
| `#work-tickets` | `work` | `@Hermes summarize assigned tickets` |
| `#daily-review` | `insights` | `@Hermes what affected focus today?` |
| `#weekly-review` | `insights` | `@Hermes summarize the week` |

If you use `#route-to-profile`, require prefixes:

```text
p: plan my personal writing project
w: summarize my current ticket load
i: what affected my focus today?
```

Ambiguous write/action requests should not be routed automatically. The bot should ask which profile owns the request.

## Bot permissions

Keep the single bot's Discord permissions minimal:

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

Because this is one bot, Discord itself is not the hard isolation boundary. The boundary comes from the gateway router plus the Hermes profile rules. If you later need stronger isolation, split this into separate bots per profile.

## Gateway dispatch contract

For every Discord message, the gateway should:

1. Resolve exactly one target profile from channel or prefix.
2. Start or continue the conversation under that Hermes profile only.
3. Load only that profile's `SOUL.md`, tools, and memory rules.
4. Enforce profile-specific write paths:
   - `personal` writes only `memory/personal/**`
   - `work` writes only `memory/work/**`
   - `insights` writes only `memory/insights/**`
5. Refuse or clarify if the request crosses contexts in a way that could leak or mutate data.

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

## Stricter option later

If you later need a stronger Discord-level permission boundary, split the gateway into separate bot applications per profile. That lets Discord channel permissions enforce bot-level separation. It is safer but more annoying day to day, so it is not the default starter setup.

## Setup sequence

1. Create the private Discord server.
2. Create categories and channels from the layout above.
3. Create one Discord application/bot named `Hermes`.
4. Invite the bot with minimal permissions.
5. Store the bot token and channel IDs in local config or Hermes profile secrets, never in git.
6. Run one Discord gateway process that routes messages to Hermes profiles by channel/prefix.
7. Send test prompts:
   - In `#personal-chat`: “@Hermes show me work radar.” Expected: refuse or ask to switch to a work channel.
   - In `#work-chat`: “@Hermes summarize personal inbox.” Expected: refuse or ask to switch to a personal channel.
   - In `#daily-review`: “@Hermes what affected focus today?” Expected: read summaries only.
