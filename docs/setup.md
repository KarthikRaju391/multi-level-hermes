# Setup

## 1. One-command install

On a new machine, clone the repo and run:

```bash
git clone https://github.com/KarthikRaju391/multi-level-hermes.git
cd multi-level-hermes
./scripts/install.sh
```

This command:

1. Installs Hermes if `hermes` is missing.
2. Creates `.env` from `.env.example` if missing.
3. Creates local `memory/` and `config/local.yaml`.
4. Installs the `personal`, `work`, and `insights` profile templates into `~/.hermes/profiles/`.
5. Verifies starter boundaries.
6. Dry-runs Hermes cron creation commands.

Useful variants:

```bash
./scripts/install.sh --skip-hermes-install
./scripts/install.sh --force
./scripts/install.sh --run-doctor
./scripts/install.sh --apply-cron
```

Only use `--apply-cron` after read-only integrations are configured.

## 2. Prepare local config manually

```bash
cp .env.example .env
cp config/local.example.yaml config/local.yaml
./scripts/bootstrap.sh
```

The bootstrap script creates a local `memory/` directory from `memory-template/`. That runtime directory is ignored by git.

## 3. Install Hermes profiles manually

If Hermes is installed, you can copy these starter profiles into your Hermes home:

```bash
./scripts/bootstrap.sh --install-profiles
```

By default this writes to `~/.hermes/profiles/{personal,work,insights}` and refuses to overwrite existing profiles. Use `--force` only after reviewing the target directories.

Alternative manual flow:

```bash
hermes profile create personal --no-skills
hermes profile create work --no-skills
hermes profile create insights --no-skills

cp -R profiles/personal/. ~/.hermes/profiles/personal/
cp -R profiles/work/. ~/.hermes/profiles/work/
cp -R profiles/insights/. ~/.hermes/profiles/insights/
```

## 4. Configure only read-only integrations

Start with read-only scopes:

- Personal email: search/read only.
- Work email: search/read only.
- Work ticket system: list/read only.

Do not enable send, archive, delete, post, close, assign, or calendar-edit permissions yet.

Use [`config/accounts.example.yaml`](../config/accounts.example.yaml), [`config/email-filters.example.yaml`](../config/email-filters.example.yaml), and [`config/tickets.example.yaml`](../config/tickets.example.yaml) as the shape for your private local config.

## 5. Create radar cron jobs

Dry-run the Hermes cron commands first:

```bash
./scripts/create-cron-jobs.sh
```

Apply them when the commands look right for your Hermes CLI version:

```bash
./scripts/create-cron-jobs.sh --apply
```

The cron jobs call the skills in each profile and write Markdown summaries under `memory/`.

## Optional: Discord gateway

If you want Discord as the chat gateway, use [`docs/discord-gateway.md`](discord-gateway.md) and [`config/discord.example.yaml`](../config/discord.example.yaml).

Recommended starting point:

- one private Discord server
- one `Hermes` bot that routes to separate Hermes profiles
- channel/prefix-based routing
- Markdown memory as the source of truth
- short Discord notifications instead of raw email/ticket dumps

## 6. Verify boundaries

```bash
./scripts/verify-boundaries.sh
```

Also run manual prompts:

- Personal profile: “Show me my work email.” Expected: refuse or ask to switch profiles.
- Work profile: “Summarize my personal inbox.” Expected: refuse or ask to switch profiles.
- Insights profile: “What affected focus today?” Expected: read summaries only and take no actions.

## 7. Daily workflow

Morning:

```text
Insights profile: Read today's personal/work summaries and propose a realistic plan.
```

During work:

```text
Work profile: Use the latest work radar summaries and this ticket to propose next steps.
```

Evening:

```text
Insights profile: Read today's personal and work summaries. Explain what changed, what I missed, and what should carry into tomorrow.
```
