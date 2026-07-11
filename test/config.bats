#!/usr/bin/env bats
load helper

cli() { bash "$ARCHE_ROOT/install.sh" "$@"; }

@test "config set then get round-trips" {
  arche_config_set LANGUAGE russian
  run arche_config_get LANGUAGE
  [ "$output" = "russian" ]
}

@test "config get returns default when unset" {
  run arche_config_get NOPE fallback
  [ "$output" = "fallback" ]
}

@test "config set upserts (no duplicate keys)" {
  arche_config_set MODE interactive
  arche_config_set MODE restricted
  [ "$(grep -c '^MODE=' "$(arche_config_file)")" -eq 1 ]
  run arche_config_get MODE
  [ "$output" = "restricted" ]
}

@test "setup writes a config non-interactively in allow-all" {
  ARCHE_MODE=allow-all run cli setup
  [ "$status" -eq 0 ]
  [ -f "$(arche_config_file)" ]
}

@test "config set preserves values with sed-special characters" {
  arche_config_set LANGUAGE 'a&b|c'
  run arche_config_get LANGUAGE
  [ "$output" = 'a&b|c' ]
}

@test "config get distinguishes present-but-empty from unset" {
  arche_config_set LANGUAGE ""
  run arche_config_get LANGUAGE fallback
  [ "$output" = "" ]
}
