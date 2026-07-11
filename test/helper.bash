# test/helper.bash — isolated environment for every test.
# Each test runs against a throwaway $HOME and config dir, so nothing touches
# the real environment, and uses fixture assets instead of the real ones.
setup() {
  ARCHE_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export ARCHE_ROOT
  TESTHOME="$(mktemp -d)"
  export HOME="$TESTHOME"
  export XDG_CONFIG_HOME="$TESTHOME/.config"
  export ARCHE_CONFIG_DIR="$XDG_CONFIG_HOME/arche"
  export ARCHE_MODE="allow-all"      # non-interactive during tests
  export ARCHE_ASSETS_ROOT="$ARCHE_ROOT/test/fixtures"
  mkdir -p "$ARCHE_CONFIG_DIR"
  # shellcheck source=/dev/null
  source "$ARCHE_ROOT/lib/core.sh"
  for a in "$ARCHE_ROOT"/lib/adapters/*.sh; do
    [ -e "$a" ] || continue
    # shellcheck source=/dev/null
    source "$a"
  done
}

teardown() {
  [ -n "${TESTHOME:-}" ] && rm -rf "$TESTHOME"
}
