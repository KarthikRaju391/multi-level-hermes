#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEMORY_ROOT="${HERMES_MEMORY_ROOT:-$REPO_ROOT/memory}"
DAY="${1:-$(date +%F)}"

mkdir -p \
  "$MEMORY_ROOT/personal/daily" \
  "$MEMORY_ROOT/personal/inbox" \
  "$MEMORY_ROOT/work/daily" \
  "$MEMORY_ROOT/work/inbox" \
  "$MEMORY_ROOT/work/tickets" \
  "$MEMORY_ROOT/insights/daily-review"

create_if_missing() {
  local path="$1"
  local title="$2"
  if [[ ! -f "$path" ]]; then
    cat > "$path" <<EOF
# $title — $DAY

## Summary

-

## Source pointers

-
EOF
    echo "Created $path"
  fi
}

create_if_missing "$MEMORY_ROOT/personal/daily/$DAY.md" "Personal Daily"
create_if_missing "$MEMORY_ROOT/personal/inbox/$DAY.md" "Personal Inbox Radar"
create_if_missing "$MEMORY_ROOT/work/daily/$DAY.md" "Work Daily"
create_if_missing "$MEMORY_ROOT/work/inbox/$DAY.md" "Work Email Radar"
create_if_missing "$MEMORY_ROOT/work/tickets/$DAY.md" "Work Ticket Radar"
create_if_missing "$MEMORY_ROOT/insights/daily-review/$DAY.md" "Daily Review"
