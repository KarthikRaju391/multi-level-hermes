# Multi-level Hermes starter

This repo is a minimal, GBrain-free starter for running Hermes with three separated contexts:

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

## What this intentionally does not include

- No GBrain.
- No raw email archive.
- No automatic email sending.
- No ticket mutation.
- No Slack posting.
- No real OAuth tokens or account credentials.

## Quick start

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

## Operating principle

Reads can be federated through the `insights` profile. Writes/actions must stay scoped to exactly one context.

> Personal and work memory stay separate. Insights reads summaries from both and writes only derived reflection.
