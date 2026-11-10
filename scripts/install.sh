#!/bin/sh
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ok(){ printf '[OK] %s\n' "$1"; }
warn(){ printf '[WARN] %s\n' "$1"; }
fail(){ printf '[FAIL] %s\n' "$1"; }

git -C "$ROOT" submodule update --init --recursive >/dev/null 2>&1 \
  && [ -d "$ROOT/vendors/open-reverselab/kb" ] && ok 'submodules present' || fail 'submodules missing'

REAV="$(npm ls -g rea-agents --json --depth=0 2>/dev/null | grep -o '"version": *"[^"]*"' | head -1 | sed 's/.*"\([0-9][^"]*\)"/\1/')"
[ -n "$REAV" ] && ok "rea-agents $REAV installed" || warn 'rea-agents not found; npm install -g rea-agents'

command -v craft-anything-cli >/dev/null 2>&1 && ok 'craft-anything-cli found' \
  || warn 'craft-anything-cli not found; see github.com/storytold/craft-anything/releases'

command -v uv >/dev/null 2>&1 && ok 'uv found' || warn 'uv not found; reverse_lab_tools unavailable'

MCPDIR="$ROOT/vendors/open-reverselab/tools/skills/mcp/ReverseLabToolsMCP"
if command -v uv >/dev/null 2>&1 && [ -f "$MCPDIR/reverse_lab_tools_mcp.py" ]; then
  claude mcp list 2>/dev/null | grep -q reverse_lab_tools \
    && ok 'reverse_lab_tools already registered' \
    || { claude mcp add --scope user reverse_lab_tools -- uv run --project "$MCPDIR" python "$MCPDIR/reverse_lab_tools_mcp.py" && ok 'reverse_lab_tools registered'; }
fi

[ -f "$ROOT/vendors/reverse-skill/refresh-tool-index.sh" ] && sh "$ROOT/vendors/reverse-skill/refresh-tool-index.sh" >/dev/null 2>&1 && ok 'reverse-skill tool index generated' || warn 'tool index step skipped'

sh "$(dirname "$0")/route-test.sh" && ok 'route-test passed' || fail 'route-test failed'
printf '%s\n' '=== unirev install report done ==='
