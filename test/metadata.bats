#!/usr/bin/env bats
load helper

@test "arche_types lists the six asset types" {
  run arche_types
  [ "$status" -eq 0 ]
  [[ "$output" == *"skills"* && "$output" == *"rules"* ]]
}

@test "arche_list_ids finds fixture skill" {
  run arche_list_ids skills
  [ "$status" -eq 0 ]
  [[ "$output" == *"demo-skill"* ]]
}

@test "arche_meta reads a frontmatter field" {
  run arche_meta skills demo-skill description
  [ "$output" = "A demo skill used in tests" ]
}

@test "arche_asset_targets reads targets field" {
  run arche_asset_targets skills demo-skill
  [ "$output" = "claude codex generic" ]
}

@test "scripts default to all targets unless overridden" {
  run arche_asset_targets scripts demo-tool
  [ "$output" = "claude generic" ]
}
