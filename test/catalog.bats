#!/usr/bin/env bats
load helper

@test "catalog has a heading and lists a fixture asset with its description" {
  run arche_catalog
  [ "$status" -eq 0 ]
  [[ "$output" == *"# Arche Catalog"* ]]
  [[ "$output" == *"demo-skill"* ]]
  [[ "$output" == *"A demo skill used in tests"* ]]
}

@test "catalog groups assets under a per-type section" {
  run arche_catalog
  [[ "$output" == *"## skills"* ]]
}
