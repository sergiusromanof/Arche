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
  grep -m1 -E "^# arche-$key:[ ]*" "$file" 2>/dev/null | sed -E "s/^# arche-$key:[ ]*//" || true
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

_arche_block_begin() { echo "# >>> arche:$1 BEGIN (managed — do not edit) >>>"; }
_arche_block_end()   { echo "# <<< arche:$1 END <<<"; }

# Insert or replace the marked region for <id> in <file>; back up first; idempotent.
arche_block_apply() {
  local file="$1" id="$2" content="$3"
  local begin end; begin="$(_arche_block_begin "$id")"; end="$(_arche_block_end "$id")"
  mkdir -p "$(dirname "$file")"
  arche_backup "$file" >/dev/null   # no-op if the file does not exist yet
  touch "$file"
  local tmp; tmp="$(mktemp)"
  if grep -qF "$begin" "$file"; then
    awk -v b="$begin" -v e="$end" -v c="$content" '
      $0==b {print; print c; skip=1; next}
      $0==e {skip=0; print; next}
      skip {next}
      {print}
    ' "$file" > "$tmp"
  else
    cp "$file" "$tmp"
    printf '\n%s\n%s\n%s\n' "$begin" "$content" "$end" >> "$tmp"
  fi
  mv "$tmp" "$file"
  arche_manifest_add block "$file" "$id"
}

# Remove only the marked region for <id> from <file>.
arche_block_remove() {
  local file="$1" id="$2"
  [ -f "$file" ] || return 0
  local begin end; begin="$(_arche_block_begin "$id")"; end="$(_arche_block_end "$id")"
  local tmp; tmp="$(mktemp)"
  awk -v b="$begin" -v e="$end" '
    $0==b {skip=1; next}
    $0==e {skip=0; next}
    skip {next}
    {print}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

arche_valid_target() { case "$1" in claude|codex|generic) return 0 ;; *) return 1 ;; esac; }

# Echo a file's body with any leading YAML frontmatter stripped.
arche_body() {
  awk 'NR==1 && $0=="---"{fm=1; next} fm && $0=="---"{fm=0; next} !fm{print}' "$1"
}

# Source path used for placement: skills link the whole directory, others the file.
arche_asset_src() {
  local type="$1" id="$2"
  if [ "$type" = "skills" ]; then echo "$(arche_type_dir skills)/$id"; else arche_asset_file "$type" "$id"; fi
}

# Install one asset into a target. Returns 0 installed, 2 skipped.
arche_install_asset() {
  local target="$1" type="$2" id="$3" mode="${4:-link}"
  "adapter_${target}_supports" "$type" || { echo "skip: $target has no place for $type"; return 2; }
  local targets; targets="$(arche_asset_targets "$type" "$id")"
  case " $targets " in
    *" $target "*) : ;;
    *) echo "skip: $type/$id not targeted at $target"; return 2 ;;
  esac
  local src dest; src="$(arche_asset_src "$type" "$id")"; dest="$("adapter_${target}_dest" "$type" "$id")"
  if [ "${ARCHE_DRY_RUN:-0}" = "1" ]; then echo "would install $type/$id -> $dest"; return 0; fi
  if [ "$type" = "rules" ]; then
    arche_block_apply "$dest" "$id" "$(arche_body "$src")"
  else
    arche_place "$src" "$dest" "$mode" || return 2
    if [ "$type" = "scripts" ] && [ -f "$dest" ]; then chmod +x "$dest"; fi
  fi
}

# Remove one asset from a target.
arche_uninstall_asset() {
  local target="$1" type="$2" id="$3"
  "adapter_${target}_supports" "$type" || return 0
  local dest; dest="$("adapter_${target}_dest" "$type" "$id")"
  if [ "$type" = "rules" ]; then arche_block_remove "$dest" "$id"; else rm -rf "$dest"; fi
}

# List the specs (type or type/id, one per line) in a profile, skipping comments and blanks.
arche_profile_specs() {
  local name="$1"
  local file="$ARCHE_ASSETS_ROOT/profiles/$name.txt"
  [ -f "$file" ] || { echo "arche: no profile '$name'" >&2; return 1; }
  grep -vE '^[[:space:]]*(#|$)' "$file"
}

arche_config_file() { echo "$ARCHE_CONFIG_DIR/config"; }

# Read a config value, or a default if the key is absent.
arche_config_get() {
  local key="$1" def="${2:-}" file val
  file="$(arche_config_file)"
  [ -f "$file" ] || { echo "$def"; return 0; }
  val="$(grep -m1 -E "^$key=" "$file" 2>/dev/null | sed -E "s/^$key=//" || true)"
  if [ -n "$val" ]; then echo "$val"; else echo "$def"; fi
}

# Insert or update a key in the config file (idempotent).
arche_config_set() {
  local key="$1" value="$2" file
  file="$(arche_config_file)"
  mkdir -p "$(dirname "$file")"; touch "$file"
  if grep -qE "^$key=" "$file"; then
    local tmp; tmp="$(mktemp)"
    sed -E "s|^$key=.*|$key=$value|" "$file" > "$tmp"
    mv "$tmp" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$file"
  fi
}
