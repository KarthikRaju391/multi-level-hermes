#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "Missing required file: $1"
}

require_file profiles/personal/SOUL.md
require_file profiles/work/SOUL.md
require_file profiles/insights/SOUL.md
require_file profiles/personal/skills/context-radar/personal-email-radar/SKILL.md
require_file profiles/work/skills/context-radar/work-email-radar/SKILL.md
require_file profiles/work/skills/context-radar/work-ticket-radar/SKILL.md
require_file profiles/insights/skills/review/daily-cross-context-review/SKILL.md
require_file config/safety-policy.md
require_file config/routing-rules.md

grep -q 'memory/personal' profiles/personal/SOUL.md || fail "Personal SOUL does not mention personal memory boundary."
grep -q 'memory/work' profiles/work/SOUL.md || fail "Work SOUL does not mention work memory boundary."
grep -q 'memory/insights' profiles/insights/SOUL.md || fail "Insights SOUL does not mention insights write boundary."

grep -qi 'Do not access.*work' profiles/personal/SOUL.md || fail "Personal SOUL should refuse work access."
grep -qi 'Do not access.*personal' profiles/work/SOUL.md || fail "Work SOUL should refuse personal access."
grep -qi 'Do not send\|Do not.*take external actions' profiles/insights/SOUL.md || fail "Insights SOUL should refuse external actions."

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git check-ignore -q .env || fail ".env is not ignored by git."
  git check-ignore -q config/local.yaml || fail "config/local.yaml is not ignored by git."
  git check-ignore -q memory/example.md || fail "runtime memory/ is not ignored by git."

  tracked_memory="$(git ls-files memory || true)"
  [[ -z "$tracked_memory" ]] || fail "Runtime memory files are tracked: $tracked_memory"
fi

echo "OK: starter boundaries look consistent."
