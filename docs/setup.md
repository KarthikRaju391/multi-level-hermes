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
2. Creates or updates `.env` with detected local paths if keys are missing.
3. Creates local `memory/` and `config/local.yaml`.
4. Installs the `personal`, `work`, and `insights` profile templates into Hermes home.
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

## 2. Update an existing setup

For an existing clone and installed profiles, run:

```bash
./scripts/update.sh
```

The updater:

1. Pulls the latest template changes from GitHub.
2. Adds missing `.env` keys without changing existing values.
3. Leaves `memory/` and `config/local.yaml` untouched.
4. Backs up existing Hermes profiles under `~/.hermes/profile-backups/`.
5. Syncs latest profile templates into Hermes home.
6. Verifies starter boundaries.
7. Dry-runs cron creation commands.

Useful variants:

```bash
./scripts/update.sh --no-pull
./scripts/update.sh --skip-profile-sync
./scripts/update.sh --run-doctor
./scripts/update.sh --apply-cron
```

Only use `--apply-cron` after reviewing integrations.

## 3. Prepare local config manually

```bash
./scripts/write-env.sh
cp config/local.example.yaml config/local.yaml
./scripts/bootstrap.sh
```

The bootstrap script creates a local `memory/` directory from `memory-template/`. That runtime directory is ignored by git.
It also creates or patches `.env` with detected local paths unless `--skip-env` is passed.

## 4. Install Hermes profiles manually

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

## 5. Configure only read-only integrations

Start with read-only scopes:

- Personal email: search/read only.
- Work email: search/read only.
- Work ticket system: list/read only.

Do not enable send, archive, delete, post, close, assign, or calendar-edit permissions yet.

Use [`config/accounts.example.yaml`](../config/accounts.example.yaml), [`config/email-filters.example.yaml`](../config/email-filters.example.yaml), and [`config/tickets.example.yaml`](../config/tickets.example.yaml) as the shape for your private local config.

For multiple personal inboxes and read-only email setup, see [`docs/email-read-access.md`](email-read-access.md).

## 6. Create radar cron jobs

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

## 7. Verify boundaries

```bash
./scripts/verify-boundaries.sh
```

Also run manual prompts:

- Personal profile: “Show me my work email.” Expected: refuse or ask to switch profiles.
- Work profile: “Summarize my personal inbox.” Expected: refuse or ask to switch profiles.
- Insights profile: “What affected focus today?” Expected: read summaries only and take no actions.

## 8. Daily workflow

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
