#!/usr/bin/env bats
load helper

cli() { bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "install claude links the demo skill" {
  run cli install claude skills
  [ "$status" -eq 0 ]
  [ -L "$HOME/.claude/skills/demo-skill" ]
}

@test "install claude injects a rule block into CLAUDE.md" {
  run cli install claude rules
  [ "$status" -eq 0 ]
  grep -q "arche:demo-rule BEGIN" "$HOME/.claude/CLAUDE.md"
  grep -q "Always be concise" "$HOME/.claude/CLAUDE.md"
}

@test "install skips assets that do not list the target" {
  # demo-tool targets 'claude generic' only; codex must skip it.
  run cli install codex scripts
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.local/bin/demo-tool" ]
}

@test "installing a script does not chmod its source through the symlink" {
  cli install claude scripts
  [ ! -x "$ARCHE_ROOT/test/fixtures/scripts/demo-tool.sh" ]
}

@test "uninstall removes the skill link" {
  cli install claude skills
  run cli uninstall claude skills
  [ ! -e "$HOME/.claude/skills/demo-skill" ]
}

@test "doctor reports installed assets" {
  cli install claude skills
  run cli doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"demo-skill"* ]]
}

@test "dry-run makes no changes" {
  run cli --dry-run install claude skills
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.claude/skills/demo-skill" ]
}
