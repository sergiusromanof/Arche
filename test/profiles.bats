#!/usr/bin/env bats
load helper

cli() { bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "profile expands to its listed assets" {
  run arche_profile_specs demo
  [[ "$output" == *"skills/demo-skill"* ]]
  [[ "$output" == *"rules/demo-rule"* ]]
}

@test "install --profile installs listed assets" {
  run cli install claude --profile demo
  [ "$status" -eq 0 ]
  [ -L "$HOME/.claude/skills/demo-skill" ]
}

@test "list --tag filters by tag" {
  run cli list --tag demo
  [[ "$output" == *"demo-skill"* ]]
  [[ "$output" != *"demo-tool"* ]]
}
