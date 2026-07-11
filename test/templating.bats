#!/usr/bin/env bats
load helper

@test "render substitutes config vars" {
  arche_config_set LANGUAGE russian
  echo "respond in {{LANGUAGE}}" > "$HOME/in.md"
  arche_render "$HOME/in.md" "$HOME/out.md"
  grep -q "respond in russian" "$HOME/out.md"
}

@test "override file takes precedence over shipped asset" {
  mkdir -p "$ARCHE_CONFIG_DIR/overrides"
  echo "OVERRIDDEN" > "$ARCHE_CONFIG_DIR/overrides/demo-rule.md"
  run arche_resolved_file rules demo-rule
  [ "$output" = "$ARCHE_CONFIG_DIR/overrides/demo-rule.md" ]
}

@test "resolved file falls back to the shipped asset" {
  run arche_resolved_file rules demo-rule
  [ "$output" = "$ARCHE_ASSETS_ROOT/rules/demo-rule.md" ]
}

@test "render substitutes mixed-case placeholders" {
  arche_config_set user_name Sergei
  echo "hi {{user_name}}" > "$HOME/in.md"
  arche_render "$HOME/in.md" "$HOME/out.md"
  grep -q "hi Sergei" "$HOME/out.md"
}
