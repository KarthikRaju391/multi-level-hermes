# Setup

## 1. Prepare local config

```bash
cp .env.example .env
cp config/local.example.yaml config/local.yaml
./scripts/bootstrap.sh
```

The bootstrap script creates a local `memory/` directory from `memory-template/`. That runtime directory is ignored by git.

## 2. Install Hermes profiles

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

## 3. Configure only read-only integrations

Start with read-only scopes:

- Personal email: search/read only.
- Work email: search/read only.
- Work ticket system: list/read only.

Do not enable send, archive, delete, post, close, assign, or calendar-edit permissions yet.

Use [`config/accounts.example.yaml`](../config/accounts.example.yaml), [`config/email-filters.example.yaml`](../config/email-filters.example.yaml), and [`config/tickets.example.yaml`](../config/tickets.example.yaml) as the shape for your private local config.

## 4. Create radar cron jobs

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
- one bot per Hermes profile
- profile-specific channel permissions
- Markdown memory as the source of truth
- short Discord notifications instead of raw email/ticket dumps

## 5. Verify boundaries

```bash
./scripts/verify-boundaries.sh
```

Also run manual prompts:

- Personal profile: “Show me my work email.” Expected: refuse or ask to switch profiles.
- Work profile: “Summarize my personal inbox.” Expected: refuse or ask to switch profiles.
- Insights profile: “What affected focus today?” Expected: read summaries only and take no actions.

## 6. Daily workflow

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
