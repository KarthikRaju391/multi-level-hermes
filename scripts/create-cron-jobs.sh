#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/create-cron-jobs.sh [--apply]

Dry-runs Hermes cron creation commands by default. Use --apply only after
profiles and read-only integrations are configured.

Environment overrides:
  HERMES_BIN                  Hermes executable (default: hermes)
  HERMES_PROFILE_FLAG         Profile flag (default: -p)
  PERSONAL_EMAIL_SCHEDULE     Default: every 4h
  WORK_EMAIL_SCHEDULE         Default: every 1h
  WORK_TICKET_SCHEDULE        Default: every 1h
  DAILY_INSIGHTS_SCHEDULE     Default: every day at 18:00
USAGE
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT_DIR="$REPO_ROOT/prompts"
HERMES_BIN="${HERMES_BIN:-hermes}"
PROFILE_FLAG="${HERMES_PROFILE_FLAG:--p}"
APPLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      APPLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

create_job() {
  local profile="$1"
  local name="$2"
  local schedule="$3"
  local skill="$4"
  local prompt_file="$5"

  if [[ ! -f "$prompt_file" ]]; then
    echo "Missing prompt file: $prompt_file" >&2
    exit 1
  fi

  if [[ "$APPLY" -eq 0 ]]; then
    echo "DRY RUN: $HERMES_BIN $PROFILE_FLAG $profile cron create \"$schedule\" \"\$(cat $prompt_file)\" --skill $skill --name $name"
    return
  fi

  "$HERMES_BIN" "$PROFILE_FLAG" "$profile" cron create "$schedule" "$(cat "$prompt_file")" --skill "$skill" --name "$name"
}

create_job \
  personal \
  personal-email-radar \
  "${PERSONAL_EMAIL_SCHEDULE:-every 4h}" \
  personal-email-radar \
  "$PROMPT_DIR/personal-email-radar.md"

create_job \
  work \
  work-email-radar \
  "${WORK_EMAIL_SCHEDULE:-every 1h}" \
  work-email-radar \
  "$PROMPT_DIR/work-email-radar.md"

create_job \
  work \
  work-ticket-radar \
  "${WORK_TICKET_SCHEDULE:-every 1h}" \
  work-ticket-radar \
  "$PROMPT_DIR/work-ticket-radar.md"

create_job \
  insights \
  daily-cross-context-review \
  "${DAILY_INSIGHTS_SCHEDULE:-every day at 18:00}" \
  daily-cross-context-review \
  "$PROMPT_DIR/daily-insights.md"

if [[ "$APPLY" -eq 0 ]]; then
  echo
  echo "No cron jobs were created. Re-run with --apply after checking the commands."
fi
