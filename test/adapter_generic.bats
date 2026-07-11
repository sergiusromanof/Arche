#!/usr/bin/env bats
load helper

@test "generic maps skills under config root" {
  run adapter_generic_dest skills demo-skill
  [ "$output" = "$ARCHE_CONFIG_DIR/skills/demo-skill" ]
}

@test "generic supports agents and commands" {
  run adapter_generic_supports agents; [ "$status" -eq 0 ]
  run adapter_generic_supports commands; [ "$status" -eq 0 ]
}

@test "generic rule file is RULES.md under config root" {
  run adapter_generic_rulefile
  [ "$output" = "$ARCHE_CONFIG_DIR/RULES.md" ]
}
