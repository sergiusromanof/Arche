#!/usr/bin/env bats
load helper

@test "each markdown asset type ships a template with a targets field" {
  for t in skill prompt command agent rule; do
    f="$(ls "$ARCHE_ROOT/templates/$t/"*.md 2>/dev/null | head -1)"
    [ -n "$f" ] || { echo "missing template for $t"; return 1; }
    grep -q '^targets:' "$f" || { echo "no targets: field in $f"; return 1; }
  done
}

@test "the script template declares arche-targets" {
  grep -q 'arche-targets' "$ARCHE_ROOT/templates/script/tool.sh"
}

@test "each asset-type folder keeps its .gitkeep so it survives empty" {
  for t in skills scripts prompts commands agents rules profiles; do
    [ -f "$ARCHE_ROOT/$t/.gitkeep" ] || { echo "missing .gitkeep in $t"; return 1; }
  done
}
