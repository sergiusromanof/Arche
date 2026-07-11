#!/usr/bin/env bash
set -euo pipefail

ARCHE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ARCHE_ROOT
: "${ARCHE_ASSETS_ROOT:=$ARCHE_ROOT}"
export ARCHE_ASSETS_ROOT

# shellcheck source=lib/core.sh
source "$ARCHE_ROOT/lib/core.sh"
for a in "$ARCHE_ROOT"/lib/adapters/*.sh; do
  # shellcheck disable=SC1090
  [ -f "$a" ] && source "$a"
done

cmd_help() {
  cat <<'EOF'
Usage: arche <command> [options]

Commands:
  list [--tag T]              List assets and their supported targets
  install <target> [asset..]  Install assets into a target
  sync [target]               Re-apply everything (after git pull)
  uninstall <target> [asset]  Remove installed assets
  doctor                      Report installation health
  setup | reconfigure         Configure Arche
  suggest                     Adaptive recommendations
  docs                        Regenerate the catalog
  help                        Show this help

Global flags: --link (default) | --copy | --dir <path> | --dry-run | --yes | --quiet | --verbose
EOF
}

cmd_list() {
  local tag_filter=""
  if [ "${1:-}" = "--tag" ]; then tag_filter="${2:-}"; fi
  local type id targets tags
  # shellcheck disable=SC2046  # intentional word-splitting of the space-separated type list
  for type in $(arche_types); do
    # shellcheck disable=SC2046  # intentional word-splitting of the newline-separated id list
    for id in $(arche_list_ids "$type"); do
      tags="$(arche_meta "$type" "$id" tags)"
      if [ -n "$tag_filter" ] && [[ " $tags " != *" $tag_filter "* ]]; then continue; fi
      targets="$(arche_asset_targets "$type" "$id")"
      printf '%-10s %-24s targets: %s\n' "$type" "$id" "$targets"
    done
  done
}

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    help|-h|--help) cmd_help ;;
    list) cmd_list "$@" ;;
    *) echo "arche: unknown command '$cmd'" >&2; cmd_help >&2; exit 1 ;;
  esac
}

main "$@"
