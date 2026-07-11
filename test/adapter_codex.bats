#!/usr/bin/env bats
load helper

@test "codex maps skills under ~/.codex/skills" {
  run adapter_codex_dest skills demo-skill
  [ "$output" = "$HOME/.codex/skills/demo-skill" ]
}

@test "codex routes commands to prompts (nearest)" {
  run adapter_codex_dest commands demo
  [ "$output" = "$HOME/.codex/prompts/demo.md" ]
}

@test "codex does not support agents" {
  run adapter_codex_supports agents
  [ "$status" -ne 0 ]
}

@test "codex rule file is AGENTS.md" {
  run adapter_codex_rulefile
  [ "$output" = "$HOME/.codex/AGENTS.md" ]
}
