#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/install.sh [options]

Install Hermes if needed, then install this starter's local memory/config and
Hermes profile templates.

Default behavior:
  1. Install Hermes with the official Linux/macOS installer if `hermes` is missing.
  2. Create/update .env with detected local paths if missing.
  3. Create runtime memory/ and config/local.yaml.
  4. Copy profiles/{personal,work,insights} into Hermes home.
  5. Verify starter boundaries.
  6. Dry-run cron creation commands.

Options:
  --force                  Overwrite matching files in existing Hermes profiles.
  --skip-hermes-install    Do not install Hermes, even if missing.
  --skip-profile-install   Do not copy profile templates into Hermes home.
  --apply-cron             Create Hermes cron jobs instead of dry-running them.
  --run-doctor             Run `hermes doctor` after installation.
  --dry-run                Print planned actions without changing files.
  -h, --help               Show this help.

Environment:
  HERMES_HOME              Defaults to ~/.hermes.
  HERMES_INSTALLER_URL     Defaults to https://hermes-agent.nousresearch.com/install.sh
USAGE
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HERMES_INSTALLER_URL="${HERMES_INSTALLER_URL:-https://hermes-agent.nousresearch.com/install.sh}"
FORCE=0
SKIP_HERMES_INSTALL=0
SKIP_PROFILE_INSTALL=0
APPLY_CRON=0
RUN_DOCTOR=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --skip-hermes-install)
      SKIP_HERMES_INSTALL=1
      shift
      ;;
    --skip-profile-install)
      SKIP_PROFILE_INSTALL=1
      shift
      ;;
    --apply-cron)
      APPLY_CRON=1
      shift
      ;;
    --run-doctor)
      RUN_DOCTOR=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
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

run() {
  echo "+ $*"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    "$@"
  fi
}

run_bash() {
  echo "+ $*"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    bash -lc "$*"
  fi
}

require_command() {
  local command_name="$1"
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "Missing required command: $command_name" >&2
    exit 1
  }
}

install_hermes_if_needed() {
  export PATH="$HOME/.local/bin:$PATH"

  if command -v hermes >/dev/null 2>&1; then
    echo "Hermes already installed: $(command -v hermes)"
    if [[ "$DRY_RUN" -eq 0 ]]; then
      hermes --version || true
    fi
    return
  fi

  if [[ "$SKIP_HERMES_INSTALL" -eq 1 ]]; then
    echo "Hermes is missing and --skip-hermes-install was set; continuing with repo setup only."
    return
  fi

  require_command curl
  require_command bash

  echo "Installing Hermes from official installer..."
  run_bash "curl -fsSL '$HERMES_INSTALLER_URL' | bash -s -- --skip-setup --skip-browser --non-interactive"
  export PATH="$HOME/.local/bin:$PATH"

  if [[ "$DRY_RUN" -eq 0 ]]; then
    if ! command -v hermes >/dev/null 2>&1; then
      echo "Hermes install finished, but hermes is still not on PATH." >&2
      echo "Try opening a new shell or adding ~/.local/bin to PATH." >&2
      exit 1
    fi
  fi

  if [[ "$DRY_RUN" -eq 0 ]]; then
    hermes --version || true
  fi
}

update_env_file() {
  run "$REPO_ROOT/scripts/write-env.sh"
}

bootstrap_starter() {
  local args=()

  if [[ "$SKIP_PROFILE_INSTALL" -eq 0 ]]; then
    args+=(--install-profiles)
    if [[ "$FORCE" -eq 1 ]]; then
      args+=(--force)
    fi
  fi

  run "$REPO_ROOT/scripts/bootstrap.sh" "${args[@]}"
}

verify_starter() {
  run "$REPO_ROOT/scripts/verify-boundaries.sh"
}

create_cron_jobs() {
  if [[ "$APPLY_CRON" -eq 1 ]]; then
    run "$REPO_ROOT/scripts/create-cron-jobs.sh" --apply
  else
    run "$REPO_ROOT/scripts/create-cron-jobs.sh"
  fi
}

run_doctor_if_requested() {
  if [[ "$RUN_DOCTOR" -ne 1 ]]; then
    return
  fi

  if ! command -v hermes >/dev/null 2>&1; then
    echo "Skipping hermes doctor because hermes is not installed."
    return
  fi

  run hermes doctor
}

main() {
  require_command git

  echo "Installing Multi-level Hermes starter from: $REPO_ROOT"
  install_hermes_if_needed
  update_env_file
  bootstrap_starter
  verify_starter
  run_doctor_if_requested
  create_cron_jobs

  cat <<NEXT

Install step complete.

Next steps:
1. Review .env and config/local.yaml for account labels and local preferences.
2. Configure read-only email/ticket integrations in Hermes.
3. If using Discord, create one bot named Hermes and set DISCORD_HERMES_BOT_TOKEN locally.
4. Re-run cron setup with --apply only after integrations are configured:
   scripts/install.sh --skip-hermes-install --apply-cron
NEXT
}

main
