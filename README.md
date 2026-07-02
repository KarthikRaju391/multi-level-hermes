# Multi-level Hermes starter

This repo is a minimal starter for running Hermes with three separated contexts:

- **Personal** — personal projects, life admin, personal email summaries.
- **Work** — work email/ticket summaries, work planning, execution context.
- **Insights** — read-only cross-context reflection over the summaries from both sides.

The starter deliberately uses **Hermes profiles + read-only radar jobs + Markdown summaries** instead of a full memory graph. The goal is to learn the boundaries before adding deeper memory systems.

```diagram
╭────────────╮       ╭────────────────────╮
│ Personal   │──────▶│ memory/personal    │
│ Hermes     │       │ email summaries    │
╰────────────╯       ╰─────────┬──────────╯
                               │ read
                               ▼
                       ╭────────────────╮
                       │ Insights       │
                       │ Hermes         │
                       ╰────────────────╯
                               ▲
                               │ read
╭────────────╮       ╭─────────┴──────────╮
│ Work       │──────▶│ memory/work        │
│ Hermes     │       │ email/ticket radar │
╰────────────╯       ╰────────────────────╯
```

## What this sets up

- Hermes profile templates in [`profiles/`](profiles/).
- Stable profile identities in `SOUL.md`.
- Minimal skills for:
  - personal email radar
  - work email radar
  - work ticket radar
  - daily cross-context insights
- Markdown memory templates in [`memory-template/`](memory-template/).
- Example routing, safety, account, and filter config in [`config/`](config/).
- Bootstrap and verification scripts in [`scripts/`](scripts/).
- Optional Discord gateway blueprint in [`docs/discord-gateway.md`](docs/discord-gateway.md).

## What this intentionally does not include

- No raw email archive.
- No automatic email sending.
- No ticket mutation.
- No Slack posting.
- No real OAuth tokens or account credentials.

## Quick start

On a new machine, clone the repo and run the installer:

```bash
git clone https://github.com/KarthikRaju391/multi-level-hermes.git
cd multi-level-hermes
./scripts/install.sh
```

The installer installs Hermes if needed, creates local config/memory, installs the profile templates, verifies the boundaries, and dry-runs cron creation.

If Hermes is already installed and you only want the starter setup:

```bash
./scripts/install.sh --skip-hermes-install
```

Manual bootstrap is also available:

```bash
cp .env.example .env
cp config/local.example.yaml config/local.yaml
./scripts/bootstrap.sh
./scripts/verify-boundaries.sh
```

Then install the profile templates into Hermes when you are ready:

```bash
./scripts/bootstrap.sh --install-profiles
```

See [`docs/setup.md`](docs/setup.md) for the full setup flow.

If you want Discord as the communication gateway, start with [`docs/discord-gateway.md`](docs/discord-gateway.md).

## Operating principle

Reads can be federated through the `insights` profile. Writes/actions must stay scoped to exactly one context.

> Personal and work memory stay separate. Insights reads summaries from both and writes only derived reflection.
