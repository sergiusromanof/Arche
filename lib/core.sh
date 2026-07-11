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

# Record a change so uninstall can reverse it exactly (deduplicated).
arche_manifest_add() {
  local kind="$1" path="$2" meta="${3:-}" mf line
  mf="$(arche_manifest_path)"
  mkdir -p "$ARCHE_CONFIG_DIR"; touch "$mf"
  line="$(printf '%s\t%s\t%s' "$kind" "$path" "$meta")"
  grep -qxF "$line" "$mf" || printf '%s\n' "$line" >> "$mf"
}

# True if the manifest records <path> as something Arche installed.
arche_manifest_has() {
  local path="$1" mf; mf="$(arche_manifest_path)"
  [ -f "$mf" ] || return 1
  awk -F'\t' -v p="$path" '$2==p{found=1} END{exit !found}' "$mf"
}

# Remove manifest lines for <path> (optionally only those whose meta == $2).
arche_manifest_remove() {
  local path="$1" meta="${2:-}" mf tmp
  mf="$(arche_manifest_path)"; [ -f "$mf" ] || return 0
  tmp="$(mktemp)"
  awk -F'\t' -v p="$path" -v m="$meta" '!(($2==p) && (m=="" || $3==m))' "$mf" > "$tmp"
  mv "$tmp" "$mf"
}

# Copy a file to a timestamped backup before it is edited; echo the backup path.
arche_backup() {
  local file="$1" bak
  [ -e "$file" ] || return 0
  bak="$file.arche.bak.$(date +%s)"
  cp -p "$file" "$bak"
  echo "$bak"
}

# True if Arche created this path: a symlink into the assets root, or a manifest-recorded install.
arche_is_ours() {
  local path="$1" tgt
  if [ -L "$path" ]; then
    tgt="$(readlink "$path")"
    case "$tgt" in "$ARCHE_ASSETS_ROOT"/*) return 0 ;; esac
  fi
  arche_manifest_has "$path"
}

# Place src at dest as a symlink (default) or copy. Returns 0 placed, 2 skipped.
# Never clobbers a file Arche did not create.
arche_place() {
  local src="$1" dest="$2" mode="${3:-link}"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if arche_is_ours "$dest"; then
      rm -rf "$dest"           # refresh our own link/copy (dir for copied skills)
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

# Insert or replace the marked region for <id> in <file>; idempotent.
# Backs up the file only when the region actually changes, so repeated syncs
# never accumulate identical backups.
arche_block_apply() {
  local file="$1" id="$2" content="$3"
  local begin end; begin="$(_arche_block_begin "$id")"; end="$(_arche_block_end "$id")"
  local existed=0; [ -e "$file" ] && existed=1
  mkdir -p "$(dirname "$file")"
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
  if cmp -s "$tmp" "$file"; then
    rm -f "$tmp"                                       # unchanged → no backup, no rewrite
  else
    if [ "$existed" = 1 ]; then arche_backup "$file" >/dev/null; fi
    mv "$tmp" "$file"
  fi
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
  local dest; dest="$("adapter_${target}_dest" "$type" "$id")"
  if [ "${ARCHE_DRY_RUN:-0}" = "1" ]; then echo "would install $type/$id -> $dest"; return 0; fi
  if [ "$type" = "rules" ] || [ "$type" = "scripts" ]; then arche_permit "$type/$id" || return 2; fi
  arche_memory_ensure "$id" >/dev/null   # ensure a persistent notes store for this asset

  # Resolve the source; a local override takes precedence over the shipped asset.
  local src tmp
  if [ "$type" = "skills" ]; then
    src="$(arche_asset_src "$type" "$id")"
    if [ -d "$ARCHE_CONFIG_DIR/overrides/$id" ]; then src="$ARCHE_CONFIG_DIR/overrides/$id"; fi
  else
    src="$(arche_resolved_file "$type" "$id")"
  fi

  if [ "$type" = "rules" ]; then
    tmp="$(mktemp)"; arche_render "$src" "$tmp"
    arche_block_apply "$dest" "$id" "$(arche_body "$tmp")"
    rm -f "$tmp"
  elif [ "$type" != "scripts" ] && grep -q '{{' "$src" 2>/dev/null; then
    tmp="$(mktemp)"; arche_render "$src" "$tmp"
    arche_place "$tmp" "$dest" copy || { rm -f "$tmp"; return 2; }
    rm -f "$tmp"
  else
    arche_place "$src" "$dest" "$mode" || return 2
    # Make copies executable, but never chmod a symlink (that would mutate the source asset).
    if [ "$type" = "scripts" ] && [ -f "$dest" ] && [ ! -L "$dest" ]; then chmod +x "$dest"; fi
  fi
  arche_usage_record install "$target/$type/$id"
}

# Remove one asset from a target.
arche_uninstall_asset() {
  local target="$1" type="$2" id="$3"
  "adapter_${target}_supports" "$type" || return 0
  local dest; dest="$("adapter_${target}_dest" "$type" "$id")"
  if [ "$type" = "rules" ]; then
    arche_block_remove "$dest" "$id"
    arche_manifest_remove "$dest" "$id"
  else
    rm -rf "$dest"
    arche_manifest_remove "$dest"
  fi
}

# List the specs (type or type/id, one per line) in a profile, skipping comments and blanks.
arche_profile_specs() {
  local name="$1"
  local file="$ARCHE_ASSETS_ROOT/profiles/$name.txt"
  [ -f "$file" ] || { echo "arche: no profile '$name'" >&2; return 1; }
  grep -vE '^[[:space:]]*(#|$)' "$file" || true   # empty/comment-only profile is not an error
}

arche_config_file() { echo "$ARCHE_CONFIG_DIR/config"; }

# Read a config value, or a default if the key is absent.
# A key present but set to an empty value returns the empty value, not the default.
arche_config_get() {
  local key="$1" def="${2:-}" file line
  file="$(arche_config_file)"
  [ -f "$file" ] || { echo "$def"; return 0; }
  line="$(grep -m1 -E "^$key=" "$file" 2>/dev/null || true)"
  if [ -n "$line" ]; then printf '%s\n' "${line#*=}"; else echo "$def"; fi
}

# Insert or update a key in the config file (idempotent).
# Drops any existing line for the key and appends the new one, so values may
# contain any characters (no sed substitution that could interpret & | \).
arche_config_set() {
  local key="$1" value="$2" file tmp
  file="$(arche_config_file)"
  mkdir -p "$(dirname "$file")"; touch "$file"
  tmp="$(mktemp)"
  grep -vE "^$key=" "$file" > "$tmp" || true
  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$file"
}

# Copy <in> to <out>, replacing {{VAR}} placeholders with config values.
arche_render() {
  local in="$1" out="$2" content var
  content="$(cat "$in")"
  while IFS= read -r var; do
    [ -z "$var" ] && continue
    content="${content//\{\{$var\}\}/$(arche_config_get "$var")}"
  done < <(grep -oE '\{\{[A-Za-z0-9_]+\}\}' "$in" 2>/dev/null | sed -E 's/[{}]//g' | sort -u)
  printf '%s\n' "$content" > "$out"
}

# Path to use for an asset: a local override wins over the shipped asset.
arche_resolved_file() {
  local type="$1" id="$2"
  local ov="$ARCHE_CONFIG_DIR/overrides/$id"
  if [ "$type" = "skills" ] && [ -d "$ov" ]; then echo "$ov/SKILL.md"; return; fi
  if [ -f "$ov.md" ]; then echo "$ov.md"; return; fi
  if [ -f "$ov" ]; then echo "$ov"; return; fi
  arche_asset_file "$type" "$id"
}

# Decide whether a risky action (rule edits, scripts on PATH) is allowed.
# Modes: allow-all (yes), restricted (no), interactive (prompt).
arche_permit() {
  local label="$1" mode
  mode="${ARCHE_MODE:-$(arche_config_get MODE interactive)}"
  case "$mode" in
    allow-all) return 0 ;;
    restricted) echo "restricted: refusing $label" >&2; return 1 ;;
    *)
      local ans
      printf 'arche: allow %s? [y/N] ' "$label" >&2
      read -r ans || true
      [ "$ans" = "y" ] || [ "$ans" = "Y" ] ;;
  esac
}

arche_memory_file() { echo "$ARCHE_CONFIG_DIR/memory/$1.md"; }

# Create the per-asset memory file if it does not exist yet; never overwrites accumulated notes.
# The file is a notes store that grows across sessions. Echoes its path.
arche_memory_ensure() {
  local id="$1" f
  f="$(arche_memory_file "$id")"
  mkdir -p "$(dirname "$f")"
  if [ ! -f "$f" ]; then
    printf '# Arche memory: %s\n\nNotes and preferences for "%s" accumulate here across sessions.\n' "$id" "$id" > "$f"
  fi
  echo "$f"
}

arche_usage_log() { echo "$ARCHE_CONFIG_DIR/usage.log"; }

# Append a usage event, but only when tracking is enabled (opt-in; default off).
arche_usage_record() {
  [ "$(arche_config_get USAGE off)" = "on" ] || return 0
  mkdir -p "$ARCHE_CONFIG_DIR"
  printf '%s\t%s\t%s\n' "$(date +%s)" "$1" "$2" >> "$(arche_usage_log)"
}

# True if the manifest already records an asset with this id (by dest basename or block meta).
arche_manifest_lists_id() {
  local id="$1" mf; mf="$(arche_manifest_path)"
  [ -f "$mf" ] || return 1
  awk -F'\t' -v id="$id" '
    { n=split($2,a,"/"); base=a[n]; sub(/\.[^.]*$/,"",base); if (base==id || $3==id) f=1 }
    END { exit !f }' "$mf"
}

# List assets that are available but not yet installed (advisory).
arche_suggest() {
  local type id
  echo "Suggestions (available but not yet installed):"
  # shellcheck disable=SC2046  # intentional word-splitting of the type list
  for type in $(arche_types); do
    # shellcheck disable=SC2046  # intentional word-splitting of the id list
    for id in $(arche_list_ids "$type"); do
      arche_manifest_lists_id "$id" || echo "  $type/$id — $(arche_meta "$type" "$id" description)"
    done
  done
}

# Print a Markdown catalog of all assets, generated from their frontmatter.
arche_catalog() {
  echo "# Arche Catalog"
  echo
  echo "_Generated by \`arche docs\` — do not edit by hand._"
  local type id ids
  # shellcheck disable=SC2046  # intentional word-splitting of the type list
  for type in $(arche_types); do
    ids="$(arche_list_ids "$type")"
    if [ -z "$ids" ]; then continue; fi
    echo; echo "## $type"; echo
    echo "| id | description | targets | tags |"
    echo "|----|-------------|---------|------|"
    # shellcheck disable=SC2086  # intentional word-splitting of the id list
    for id in $ids; do
      printf '| %s | %s | %s | %s |\n' "$id" \
        "$(arche_meta "$type" "$id" description)" \
        "$(arche_asset_targets "$type" "$id")" \
        "$(arche_meta "$type" "$id" tags)"
    done
  done
}

arche_local_version() { cat "$ARCHE_ROOT/VERSION" 2>/dev/null || echo "0.0.0"; }

# Return 0 if semver <a> is greater than <b> (tolerates a leading 'v').
arche_version_gt() {
  local a="${1#v}" b="${2#v}"
  [ "$a" = "$b" ] && return 1
  local hi; hi="$(printf '%s\n%s\n' "$a" "$b" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"
  [ "$hi" = "$a" ]
}

arche_check_stamp() { echo "$ARCHE_CONFIG_DIR/last-update-check"; }

# Return 0 if we should check for updates: no stamp yet, or the stamp is older than 24h.
arche_should_check() {
  local now="$1" stamp last
  stamp="$(arche_check_stamp)"
  [ -f "$stamp" ] || return 0
  last="$(cat "$stamp" 2>/dev/null || echo 0)"
  [ "$(( now - last ))" -ge 86400 ]
}

# Latest release tag in the checkout (empty if none or not a git checkout).
arche_latest_tag() { git -C "$ARCHE_ROOT" tag --sort=-v:refname 2>/dev/null | head -1; }
