#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap.sh [--install-profiles] [--force] [--skip-env]

Creates local runtime memory from memory-template/ and optionally copies profile
templates into Hermes.

Options:
  --install-profiles  Copy profiles/{personal,work,insights} into Hermes home.
  --force             When installing profiles, overwrite matching files in existing targets.
  --skip-env          Do not create/update .env.
  -h, --help          Show this help.
USAGE
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_PROFILES=0
FORCE=0
SKIP_ENV=0

load_env_file() {
  if [[ -f "$REPO_ROOT/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-profiles)
      INSTALL_PROFILES=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --skip-env)
      SKIP_ENV=1
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

if [[ "$SKIP_ENV" -ne 1 ]]; then
  "$REPO_ROOT/scripts/write-env.sh"
fi

load_env_file

MEMORY_ROOT="${HERMES_MEMORY_ROOT:-$REPO_ROOT/memory}"
HERMES_HOME_DIR="${HERMES_HOME:-$HOME/.hermes}"

echo "Repo: $REPO_ROOT"
echo "Memory root: $MEMORY_ROOT"

if [[ ! -d "$MEMORY_ROOT" ]]; then
  mkdir -p "$(dirname "$MEMORY_ROOT")"
  cp -R "$REPO_ROOT/memory-template" "$MEMORY_ROOT"
  echo "Created runtime memory at $MEMORY_ROOT"
else
  echo "Runtime memory already exists; leaving it unchanged."
fi

if [[ ! -f "$REPO_ROOT/config/local.yaml" ]]; then
  cp "$REPO_ROOT/config/local.example.yaml" "$REPO_ROOT/config/local.yaml"
  echo "Created config/local.yaml from example."
else
  echo "config/local.yaml already exists; leaving it unchanged."
fi

if [[ "$INSTALL_PROFILES" -eq 1 ]]; then
  PROFILE_DEST="$HERMES_HOME_DIR/profiles"
  mkdir -p "$PROFILE_DEST"

  for profile in personal work insights; do
    src="$REPO_ROOT/profiles/$profile"
    dest="$PROFILE_DEST/$profile"

    if [[ -d "$dest" && "$FORCE" -ne 1 ]]; then
      echo "Skipping existing Hermes profile: $dest"
      echo "  Re-run with --force to merge template files into this profile."
      continue
    fi

    mkdir -p "$dest"
    cp -R "$src/." "$dest/"
    echo "Installed profile template: $profile -> $dest"
  done
fi

cat <<NEXT

Next steps:
1. Review config/local.yaml and .env locally.
2. Configure read-only email/ticket integrations in Hermes.
3. Run: scripts/verify-boundaries.sh
4. Dry-run cron creation: scripts/create-cron-jobs.sh
NEXT
