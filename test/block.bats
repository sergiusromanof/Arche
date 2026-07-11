#!/usr/bin/env bats
load helper

@test "block_apply appends a marked region and is idempotent" {
  f="$HOME/CLAUDE.md"; printf 'user top\n' > "$f"
  arche_block_apply "$f" demo-rule "Be concise."
  arche_block_apply "$f" demo-rule "Be concise."   # second run must not duplicate
  [ "$(grep -c 'arche:demo-rule BEGIN' "$f")" -eq 1 ]
  grep -q 'user top' "$f"
  grep -q 'Be concise.' "$f"
}

@test "block_apply replaces existing region content" {
  f="$HOME/CLAUDE.md"; : > "$f"
  arche_block_apply "$f" demo-rule "First."
  arche_block_apply "$f" demo-rule "Second."
  grep -q 'Second.' "$f"
  ! grep -q 'First.' "$f"
}

@test "block_remove deletes only its region" {
  f="$HOME/CLAUDE.md"; printf 'keep me\n' > "$f"
  arche_block_apply "$f" demo-rule "Bye."
  arche_block_remove "$f" demo-rule
  grep -q 'keep me' "$f"
  ! grep -q 'arche:demo-rule' "$f"
}

@test "re-applying an unchanged rule creates no new backup" {
  f="$HOME/CLAUDE.md"
  arche_block_apply "$f" demo-rule "Be concise."
  before="$(find "$HOME" -name 'CLAUDE.md.arche.bak.*' | wc -l | tr -d ' ')"
  arche_block_apply "$f" demo-rule "Be concise."
  after="$(find "$HOME" -name 'CLAUDE.md.arche.bak.*' | wc -l | tr -d ' ')"
  [ "$before" = "$after" ]
}

@test "changing a pre-existing rule file backs it up once" {
  f="$HOME/CLAUDE.md"; printf 'user\n' > "$f"
  arche_block_apply "$f" demo-rule "First."
  n="$(find "$HOME" -name 'CLAUDE.md.arche.bak.*' | wc -l | tr -d ' ')"
  [ "$n" -ge 1 ]
}
