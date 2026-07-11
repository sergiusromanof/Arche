#!/usr/bin/env bats
load helper

@test "claude adapter maps skills under ~/.claude/skills" {
  run adapter_claude_dest skills demo-skill
  [ "$output" = "$HOME/.claude/skills/demo-skill" ]
}

@test "claude adapter maps commands under ~/.claude/commands" {
  run adapter_claude_dest commands demo
  [ "$output" = "$HOME/.claude/commands/demo.md" ]
}

@test "claude adapter maps scripts into ~/.local/bin" {
  run adapter_claude_dest scripts demo-tool
  [ "$output" = "$HOME/.local/bin/demo-tool" ]
}

@test "claude adapter rule file is CLAUDE.md" {
  run adapter_claude_rulefile
  [ "$output" = "$HOME/.claude/CLAUDE.md" ]
}

@test "claude adapter supports agents" {
  run adapter_claude_supports agents
  [ "$status" -eq 0 ]
}
