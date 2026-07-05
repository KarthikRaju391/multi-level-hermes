#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/update.sh [options]

Update an existing Multi-level Hermes checkout and installed Hermes profiles to
the latest template version without touching runtime memory or local secrets.

Default behavior:
  1. Pull latest template changes from the GitHub remote with a fast-forward merge.
  2. Create/update .env with missing machine-local keys only.
  3. Ensure memory/ and config/local.yaml exist without overwriting them.
  4. Back up existing Hermes profiles.
  5. Sync latest profile templates into Hermes home.
  6. Verify starter boundaries.
  7. Dry-run cron creation commands.

Options:
  --no-pull              Skip git fetch/merge.
  --skip-profile-sync    Do not sync profile templates into Hermes home.
  --apply-cron           Create Hermes cron jobs instead of dry-running them.
  --run-doctor           Run `hermes doctor` after update.
  --dry-run              Print planned actions without changing files.
  -h, --help             Show this help.

Environment:
  HERMES_HOME              Defaults to ~/.hermes.
  HERMES_TEMPLATE_REMOTE   Defaults to the GitHub remote if present, else origin.
  HERMES_TEMPLATE_BRANCH   Defaults to main.
USAGE
}

ORIGINAL_ARGS=("$@")
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NO_PULL=0
SKIP_PROFILE_SYNC=0
APPLY_CRON=0
RUN_DOCTOR=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-pull)
      NO_PULL=1
      shift
      ;;
    --skip-profile-sync)
      SKIP_PROFILE_SYNC=1
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

choose_remote() {
  if [[ -n "${HERMES_TEMPLATE_REMOTE:-}" ]]; then
    printf '%s\n' "$HERMES_TEMPLATE_REMOTE"
    return
  fi

  if git -C "$REPO_ROOT" remote get-url origin >/dev/null 2>&1; then
    local origin_url
    origin_url="$(git -C "$REPO_ROOT" remote get-url origin)"
    if [[ "$origin_url" == *github.com*KarthikRaju391/multi-level-hermes* ]]; then
      printf '%s\n' origin
      return
    fi
  fi

  if git -C "$REPO_ROOT" remote get-url github >/dev/null 2>&1; then
    printf '%s\n' github
    return
  fi

  printf '%s\n' origin
}

ensure_clean_for_pull() {
  local dirty
  dirty="$(git -C "$REPO_ROOT" status --porcelain --untracked-files=no)"
  if [[ -n "$dirty" ]]; then
    echo "Refusing to pull because tracked files have local changes:" >&2
    printf '%s\n' "$dirty" >&2
    echo "Commit/stash them, or rerun with --no-pull to only sync local templates." >&2
    exit 1
  fi
}

pull_latest() {
  if [[ "$NO_PULL" -eq 1 ]]; then
    echo "Skipping git pull because --no-pull was set."
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: would fetch and fast-forward merge latest template changes."
    return
  fi

  ensure_clean_for_pull

  local remote branch old_head new_head
  remote="$(choose_remote)"
  branch="${HERMES_TEMPLATE_BRANCH:-main}"
  old_head="$(git -C "$REPO_ROOT" rev-parse HEAD)"

  git -C "$REPO_ROOT" fetch "$remote" "$branch"
  git -C "$REPO_ROOT" merge --ff-only FETCH_HEAD

  new_head="$(git -C "$REPO_ROOT" rev-parse HEAD)"
  if [[ "$old_head" != "$new_head" && "${HERMES_UPDATE_REEXECED:-0}" != "1" ]]; then
    echo "Template updated; restarting updater from the latest script."
    HERMES_UPDATE_REEXECED=1 exec "$REPO_ROOT/scripts/update.sh" --no-pull "${ORIGINAL_ARGS[@]}"
  fi
}

detect_hermes_home() {
  if [[ -n "${HERMES_HOME:-}" ]]; then
    printf '%s\n' "$HERMES_HOME"
  else
    printf '%s\n' "$HOME/.hermes"
  fi
}

load_env_file() {
  if [[ -f "$REPO_ROOT/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
  fi
}

backup_profiles() {
  if [[ "$SKIP_PROFILE_SYNC" -eq 1 ]]; then
    return
  fi

  local hermes_home profile_dest backup_root profile dest
  hermes_home="$(detect_hermes_home)"
  profile_dest="$hermes_home/profiles"
  backup_root="$hermes_home/profile-backups/$(date +%Y%m%d-%H%M%S)"

  for profile in personal work insights; do
    dest="$profile_dest/$profile"
    if [[ -d "$dest" ]]; then
      run mkdir -p "$backup_root"
      run cp -R "$dest" "$backup_root/$profile"
      echo "Backed up $profile profile to $backup_root/$profile"
    fi
  done
}

sync_profiles_and_runtime() {
  run "$REPO_ROOT/scripts/write-env.sh"

  if [[ "$DRY_RUN" -eq 0 ]]; then
    load_env_file
  fi

  if [[ "$SKIP_PROFILE_SYNC" -eq 1 ]]; then
    run "$REPO_ROOT/scripts/bootstrap.sh"
  else
    backup_profiles
    run "$REPO_ROOT/scripts/bootstrap.sh" --install-profiles --force
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

run_cron_step() {
  if [[ "$APPLY_CRON" -eq 1 ]]; then
    run "$REPO_ROOT/scripts/create-cron-jobs.sh" --apply
  else
    run "$REPO_ROOT/scripts/create-cron-jobs.sh"
  fi
}

main() {
  echo "Updating Multi-level Hermes starter at: $REPO_ROOT"
  pull_latest
  sync_profiles_and_runtime
  run "$REPO_ROOT/scripts/verify-boundaries.sh"
  run_doctor_if_requested
  run_cron_step

  cat <<NEXT

Update complete.

Notes:
- .env values were preserved; only missing keys were added.
- Runtime memory/ and config/local.yaml were not overwritten.
- Existing Hermes profiles were backed up before template sync when profile sync was enabled.
- Cron creation is dry-run by default. Use --apply-cron only after reviewing integrations.
NEXT
}

main
