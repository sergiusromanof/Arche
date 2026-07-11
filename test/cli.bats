#!/usr/bin/env bats
load helper

cli() { ARCHE_ASSETS_ROOT="$ARCHE_ROOT/test/fixtures" bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "help prints usage" {
  run cli help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: arche"* ]]
}

@test "list shows fixture assets and their targets" {
  run cli list
  [ "$status" -eq 0 ]
  [[ "$output" == *"demo-skill"* ]]
  [[ "$output" == *"claude"* ]]
}

@test "unknown command exits non-zero" {
  run cli bogus
  [ "$status" -ne 0 ]
}
