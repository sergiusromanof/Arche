#!/usr/bin/env bats
load helper

cli() { bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "memory_ensure creates a memory file with a header naming the asset" {
  run arche_memory_ensure demo-skill
  [ "$status" -eq 0 ]
  [ -f "$output" ]
  grep -q "demo-skill" "$output"
}

@test "installing an asset creates its memory file" {
  cli install claude skills
  [ -f "$ARCHE_CONFIG_DIR/memory/demo-skill.md" ]
}

@test "re-install preserves accumulated memory notes" {
  cli install claude skills
  echo "ACCUMULATED NOTE" >> "$ARCHE_CONFIG_DIR/memory/demo-skill.md"
  cli install claude skills
  grep -q "ACCUMULATED NOTE" "$ARCHE_CONFIG_DIR/memory/demo-skill.md"
}

@test "dry-run does not create a memory file" {
  cli --dry-run install claude skills
  [ ! -e "$ARCHE_CONFIG_DIR/memory/demo-skill.md" ]
}
