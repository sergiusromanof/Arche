#!/usr/bin/env bats
load helper

cli() { bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "arche_is_ours recognizes a manifest-tracked copy" {
  src="$ARCHE_ROOT/test/fixtures/rules/demo-rule.md"
  dest="$HOME/x/copy.md"
  arche_place "$src" "$dest" copy
  run arche_is_ours "$dest"
  [ "$status" -eq 0 ]
}

@test "re-placing a copied file refreshes it instead of skipping" {
  src="$ARCHE_ROOT/test/fixtures/rules/demo-rule.md"
  dest="$HOME/x/copy.md"
  arche_place "$src" "$dest" copy
  run arche_place "$src" "$dest" copy
  [ "$status" -eq 0 ]
}

@test "no-clobber still protects a file Arche did not create" {
  src="$ARCHE_ROOT/test/fixtures/rules/demo-rule.md"
  dest="$HOME/x/user.md"
  mkdir -p "$HOME/x"; echo "user content" > "$dest"
  run arche_place "$src" "$dest" copy
  [ "$status" -eq 2 ]
  [ "$(cat "$dest")" = "user content" ]
}

@test "uninstall prunes the manifest entry" {
  cli install claude skills
  cli uninstall claude skills
  run grep -c "demo-skill" "$(arche_manifest_path)"
  [ "$output" -eq 0 ]
}
