#!/bin/bash
set -uo pipefail

# Only run in Claude Code cloud sessions.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

AGENTS_DIR="$CLAUDE_PROJECT_DIR/.claude/agents"
TMP_DIR="$(mktemp -d)"

if git clone --depth 1 https://github.com/msitarzewski/agency-agents "$TMP_DIR" >/dev/null 2>&1; then
  rm -rf "$AGENTS_DIR"
  mkdir -p "$AGENTS_DIR"
  if "$TMP_DIR/scripts/install.sh" --tool claude-code --path "$AGENTS_DIR" >/dev/null 2>&1; then
    echo "agency-agents: synced $(ls "$AGENTS_DIR" | wc -l) agent definitions from msitarzewski/agency-agents"
  else
    echo "agency-agents: install.sh failed, falling back to raw copy"
    find "$TMP_DIR" -mindepth 2 -maxdepth 2 -iname "*.md" -not -iname "README.md" -not -iname "QUICKSTART.md" -not -iname "EXECUTIVE-BRIEF.md" -exec cp {} "$AGENTS_DIR/" \;
    echo "agency-agents: synced $(ls "$AGENTS_DIR" | wc -l) agent definitions (fallback copy)"
  fi
else
  echo "agency-agents: sync skipped (could not reach github.com/msitarzewski/agency-agents)"
fi

rm -rf "$TMP_DIR"
exit 0
