#!/bin/sh
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ok(){ printf '[OK] %s\n' "$1"; }
warn(){ printf '[WARN] %s\n' "$1"; }
fail(){ printf '[FAIL] %s\n' "$1"; }

git -C "$ROOT" submodule update --init --recursive >/dev/null 2>&1 \
  && [ -d "$ROOT/vendors/open-reverselab/kb" ] && ok 'submodules present' || fail 'submodules missing'

REAV="$(npm ls -g rea-agents --json --depth=0 2>/dev/null | grep -o '"version": *"[^"]*"' | head -1 | sed 's/.*"\([0-9][^"]*\)"/\1/')"
if [ -n "$REAV" ]; then
  ok "rea-agents $REAV installed"
else
  printf '[INFO] %s\n' 'rea-agents not found; installing globally (idempotent)...'
  if npm install -g rea-agents >/dev/null 2>&1; then ok 'rea-agents installed via npm install -g'
  else warn 'rea-agents auto-install failed; run manually: npm install -g rea-agents'; fi
fi

command -v craft-anything-cli >/dev/null 2>&1 && ok 'craft-anything-cli found' \
  || warn 'craft-anything-cli not found; see github.com/storytold/craft-anything/releases'

command -v uv >/dev/null 2>&1 && ok 'uv found' || warn 'uv not found; reverse_lab_tools unavailable'

MCPDIR="$ROOT/vendors/open-reverselab/tools/skills/mcp/ReverseLabToolsMCP"
if command -v uv >/dev/null 2>&1 && [ -f "$MCPDIR/reverse_lab_tools_mcp.py" ]; then
  # 上游 requires-python 声明 >=3.10 但代码使用 tomllib（3.11+ 标准库），故显式钉 >=3.11
  claude mcp list 2>/dev/null | grep -q reverse_lab_tools \
    && ok 'reverse_lab_tools already registered' \
    || { claude mcp add --scope user reverse_lab_tools -- uv run --project "$MCPDIR" --python '>=3.11' python "$MCPDIR/reverse_lab_tools_mcp.py" && ok 'reverse_lab_tools registered'; }
fi

[ -f "$ROOT/vendors/reverse-skill/skills/scripts/refresh-tool-index.sh" ] && sh "$ROOT/vendors/reverse-skill/skills/scripts/refresh-tool-index.sh" >/dev/null 2>&1 && ok 'reverse-skill tool index generated' || warn 'tool index step skipped'

sh "$(dirname "$0")/route-test.sh" && ok 'route-test passed' || fail 'route-test failed'
printf '%s\n' '=== unirev install report done ==='
