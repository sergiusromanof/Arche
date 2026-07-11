#!/usr/bin/env bash
set -euo pipefail

ARCHE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ARCHE_ROOT
: "${ARCHE_ASSETS_ROOT:=$ARCHE_ROOT}"
export ARCHE_ASSETS_ROOT

# shellcheck source=lib/core.sh
source "$ARCHE_ROOT/lib/core.sh"
for a in "$ARCHE_ROOT"/lib/adapters/*.sh; do
  [ -e "$a" ] || continue
  # shellcheck disable=SC1090
  source "$a"
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

Targets: claude codex generic
Global flags: --link (default) | --copy | --dir <path> | --dry-run | --yes
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

# Expand a list of specs (types or type/id) and install each into a target.
cmd_install() {
  local target="${1:-}"; shift || true
  arche_valid_target "$target" || { echo "arche: unknown target '$target'" >&2; exit 1; }
  local mode="${ARCHE_MODE_LINK:-link}"
  local specs
  if [ "$#" -gt 0 ]; then specs="$*"; else specs="$(arche_types)"; fi
  local spec type id
  # shellcheck disable=SC2086  # intentional word-splitting of the spec list
  for spec in $specs; do
    if [ "${spec%/*}" != "$spec" ]; then
      type="${spec%%/*}"; id="${spec#*/}"
      arche_install_asset "$target" "$type" "$id" "$mode" || true
    else
      type="$spec"
      # shellcheck disable=SC2046  # intentional word-splitting of the id list
      for id in $(arche_list_ids "$type"); do
        arche_install_asset "$target" "$type" "$id" "$mode" || true
      done
    fi
  done
}

cmd_sync() {
  local targets t
  if [ "$#" -gt 0 ]; then targets="$*"; else targets="claude codex generic"; fi
  # shellcheck disable=SC2086  # intentional word-splitting of the target list
  for t in $targets; do
    arche_valid_target "$t" && cmd_install "$t"
  done
}

cmd_uninstall() {
  local target="${1:-}"; shift || true
  arche_valid_target "$target" || { echo "arche: unknown target '$target'" >&2; exit 1; }
  local specs
  if [ "$#" -gt 0 ]; then specs="$*"; else specs="$(arche_types)"; fi
  local spec type id
  # shellcheck disable=SC2086  # intentional word-splitting of the spec list
  for spec in $specs; do
    if [ "${spec%/*}" != "$spec" ]; then
      type="${spec%%/*}"; id="${spec#*/}"
      arche_uninstall_asset "$target" "$type" "$id" || true
    else
      type="$spec"
      # shellcheck disable=SC2046  # intentional word-splitting of the id list
      for id in $(arche_list_ids "$type"); do
        arche_uninstall_asset "$target" "$type" "$id" || true
      done
    fi
  done
}

cmd_doctor() {
  echo "Arche doctor"
  local mf; mf="$(arche_manifest_path)"
  if [ ! -f "$mf" ]; then echo "nothing installed yet"; return 0; fi
  local kind path meta
  while IFS=$'\t' read -r kind path meta; do
    case "$kind" in
      link|copy)
        if [ -e "$path" ]; then echo "ok   $kind $path"; else echo "MISS $kind $path"; fi ;;
      block)
        if grep -q "arche:$meta BEGIN" "$path" 2>/dev/null; then echo "ok   block $meta in $path"; else echo "MISS block $meta in $path"; fi ;;
    esac
  done < "$mf"
}

main() {
  ARCHE_DRY_RUN=0; ARCHE_MODE_LINK="link"; ARCHE_TARGET_DIR=""
  local -a rest=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) ARCHE_DRY_RUN=1 ;;
      --copy) ARCHE_MODE_LINK="copy" ;;
      --link) ARCHE_MODE_LINK="link" ;;
      --yes) ARCHE_MODE="allow-all" ;;
      --dir) shift; ARCHE_TARGET_DIR="${1:-}" ;;
      *) rest+=("$1") ;;
    esac
    shift
  done
  export ARCHE_DRY_RUN ARCHE_TARGET_DIR ARCHE_MODE
  if [ "${#rest[@]}" -gt 0 ]; then set -- "${rest[@]}"; else set --; fi
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    help|-h|--help) cmd_help ;;
    list) cmd_list "$@" ;;
    install) arche_require_not_root; cmd_install "$@" ;;
    sync) arche_require_not_root; cmd_sync "$@" ;;
    uninstall) cmd_uninstall "$@" ;;
    doctor) cmd_doctor "$@" ;;
    *) echo "arche: unknown command '$cmd'" >&2; cmd_help >&2; exit 1 ;;
  esac
}

main "$@"
