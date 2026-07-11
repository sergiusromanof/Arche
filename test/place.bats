#!/usr/bin/env bats
load helper

@test "place link creates a symlink and records manifest" {
  src="$ARCHE_ROOT/test/fixtures/rules/demo-rule.md"
  dest="$HOME/dest/demo-rule.md"
  run arche_place "$src" "$dest" link
  [ "$status" -eq 0 ]
  [ -L "$dest" ]
  grep -q "$dest" "$(arche_manifest_path)"
}

@test "place copy creates a real file" {
  src="$ARCHE_ROOT/test/fixtures/rules/demo-rule.md"
  dest="$HOME/dest/copy.md"
  run arche_place "$src" "$dest" copy
  [ "$status" -eq 0 ]
  [ -f "$dest" ] && [ ! -L "$dest" ]
}

@test "no-clobber: refuses to overwrite a non-Arche file" {
  src="$ARCHE_ROOT/test/fixtures/rules/demo-rule.md"
  dest="$HOME/dest/user.md"
  mkdir -p "$HOME/dest"; echo "user content" > "$dest"
  run arche_place "$src" "$dest" link
  [ "$status" -eq 2 ]
  [ "$(cat "$dest")" = "user content" ]
}

@test "backup copies an existing file with a timestamped suffix" {
  f="$HOME/CLAUDE.md"; echo "orig" > "$f"
  run arche_backup "$f"
  [ "$status" -eq 0 ]
  [ -f "$output" ]
  [ "$(cat "$output")" = "orig" ]
}
