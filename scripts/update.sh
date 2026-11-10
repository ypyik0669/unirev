#!/bin/sh
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo '== unirev update =='
git -C "$ROOT" submodule update --remote --recursive
npm update -g rea-agents
echo '-- craft-anything-cli: re-run install.sh for release refresh --'
sh "$ROOT/scripts/install.sh"
