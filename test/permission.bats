#!/usr/bin/env bats
load helper

cli() { bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "restricted mode refuses rule edits" {
  ARCHE_MODE=restricted run cli install claude rules
  [ ! -f "$HOME/.claude/CLAUDE.md" ] || ! grep -q "arche:demo-rule" "$HOME/.claude/CLAUDE.md"
}

@test "restricted mode refuses scripts on PATH" {
  ARCHE_MODE=restricted run cli install claude scripts
  [ ! -e "$HOME/.local/bin/demo-tool" ]
}

@test "allow-all installs risky assets" {
  ARCHE_MODE=allow-all run cli install claude rules
  grep -q "arche:demo-rule" "$HOME/.claude/CLAUDE.md"
}
