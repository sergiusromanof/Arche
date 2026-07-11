#!/usr/bin/env bats
load helper

cli() { bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "usage tracking is opt-in: no log unless enabled" {
  cli install claude skills
  [ ! -f "$(arche_usage_log)" ]
}

@test "enabling usage records installs" {
  arche_config_set USAGE on
  cli install claude skills
  [ -f "$(arche_usage_log)" ]
  grep -q "install" "$(arche_usage_log)"
}

@test "suggest lists an available but uninstalled asset" {
  cli install claude skills
  run cli suggest
  [ "$status" -eq 0 ]
  [[ "$output" == *"demo-rule"* ]]
}

@test "suggest omits an already-installed asset" {
  cli install claude skills
  run cli suggest
  [[ "$output" != *"demo-skill"* ]]
}
