#!/usr/bin/env bats
load helper

@test "--install-shim installs an arche symlink into ~/.local/bin" {
  run bash "$ARCHE_ROOT/install.sh" --install-shim
  [ "$status" -eq 0 ]
  [ -L "$HOME/.local/bin/arche" ]
}

@test "the installed shim points at install.sh" {
  bash "$ARCHE_ROOT/install.sh" --install-shim
  [ "$(readlink "$HOME/.local/bin/arche")" = "$ARCHE_ROOT/install.sh" ]
}

@test "--install-shim refuses to overwrite a non-symlink at the target" {
  mkdir -p "$HOME/.local/bin"; echo "mine" > "$HOME/.local/bin/arche"
  run bash "$ARCHE_ROOT/install.sh" --install-shim
  [ "$status" -ne 0 ]
  [ "$(cat "$HOME/.local/bin/arche")" = "mine" ]
}
