#!/usr/bin/env bash
# lib/core.sh — Arche engine. Sourced by install.sh and tests.
set -o pipefail

: "${ARCHE_ASSETS_ROOT:=${ARCHE_ROOT:-.}}"
: "${ARCHE_CONFIG_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}/arche}"

arche_types() { echo "skills scripts prompts commands agents rules"; }

arche_type_dir() { echo "$ARCHE_ASSETS_ROOT/$1"; }

# List asset ids for a type. Skills are directories; everything else is files.
arche_list_ids() {
  local type="$1" dir; dir="$(arche_type_dir "$type")"
  [ -d "$dir" ] || return 0
  if [ "$type" = "skills" ]; then
    find "$dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  else
    find "$dir" -mindepth 1 -maxdepth 1 -type f ! -name '.gitkeep' \
      -exec basename {} \; | sed 's/\.[^.]*$//' | sort
  fi
}

# Primary file for an asset (SKILL.md for skills, the file itself otherwise).
arche_asset_file() {
  local type="$1" id="$2" dir; dir="$(arche_type_dir "$type")"
  if [ "$type" = "skills" ]; then
    echo "$dir/$id/SKILL.md"
  else
    local f; f="$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "$id.*" | head -n1)"
    echo "$f"
  fi
}

# Read a single-line frontmatter field (between the first two --- lines).
_arche_frontmatter_field() {
  local file="$1" field="$2"
  [ -f "$file" ] || return 0
  awk -v f="$field" '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { exit }
    infm {
      if ($0 ~ "^"f":[ \t]*") { sub("^"f":[ \t]*",""); print; exit }
    }' "$file"
}

# Read an `# arche-<key>:` comment from a script.
_arche_script_field() {
  local file="$1" key="$2"
  [ -f "$file" ] || return 0
  grep -m1 -E "^# arche-$key:[ ]*" "$file" 2>/dev/null | sed -E "s/^# arche-$key:[ ]*//"
}

# Read a metadata field for any asset.
arche_meta() {
  local type="$1" id="$2" field="$3" file; file="$(arche_asset_file "$type" "$id")"
  if [ "$type" = "scripts" ]; then
    _arche_script_field "$file" "$field"
  else
    _arche_frontmatter_field "$file" "$field"
  fi
}

# Targets an asset supports (scripts default to all targets when unset).
arche_asset_targets() {
  local type="$1" id="$2" t; t="$(arche_meta "$type" "$id" targets)"
  if [ -z "$t" ]; then
    if [ "$type" = "scripts" ]; then t="claude codex generic"; fi
  fi
  echo "$t"
}

arche_require_not_root() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "arche: refusing to run as root" >&2
    exit 1
  fi
}

arche_manifest_path() { echo "$ARCHE_CONFIG_DIR/manifest"; }

# Record a change so uninstall can reverse it exactly.
arche_manifest_add() {
  local kind="$1" path="$2" meta="${3:-}"
  mkdir -p "$ARCHE_CONFIG_DIR"
  printf '%s\t%s\t%s\n' "$kind" "$path" "$meta" >> "$(arche_manifest_path)"
}

# Copy a file to a timestamped backup before it is edited; echo the backup path.
arche_backup() {
  local file="$1" bak
  [ -e "$file" ] || return 0
  bak="$file.arche.bak.$(date +%s)"
  cp -p "$file" "$bak"
  echo "$bak"
}

# True if path is a symlink Arche created (points inside the assets root).
arche_is_ours() {
  local path="$1" tgt
  [ -L "$path" ] || return 1
  tgt="$(readlink "$path")"
  case "$tgt" in "$ARCHE_ASSETS_ROOT"/*) return 0 ;; *) return 1 ;; esac
}

# Place src at dest as a symlink (default) or copy. Returns 0 placed, 2 skipped.
# Never clobbers a file Arche did not create.
arche_place() {
  local src="$1" dest="$2" mode="${3:-link}"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if arche_is_ours "$dest"; then
      rm -f "$dest"            # refresh our own link/copy
    else
      echo "arche: skip (exists, not managed): $dest" >&2
      return 2
    fi
  fi
  if [ "$mode" = "copy" ]; then
    cp -R "$src" "$dest"
    arche_manifest_add copy "$dest" "$src"
  else
    ln -s "$src" "$dest"
    arche_manifest_add link "$dest" "$src"
  fi
  return 0
}
