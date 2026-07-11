#!/usr/bin/env bash
# Codex (OpenAI) adapter — where each asset type installs under ~/.codex.

adapter_codex_root() { echo "${ARCHE_TARGET_DIR:-$HOME/.codex}"; }

adapter_codex_supports() {
  case "$1" in skills|prompts|commands|scripts|rules) return 0 ;; *) return 1 ;; esac
}

adapter_codex_rulefile() { echo "$(adapter_codex_root)/AGENTS.md"; }

adapter_codex_dest() {
  local type="$1" id="$2" root; root="$(adapter_codex_root)"
  case "$type" in
    skills)            echo "$root/skills/$id" ;;
    prompts|commands)  echo "$root/prompts/$id.md" ;;   # commands map to the nearest concept: prompts
    scripts)           echo "$HOME/.local/bin/$id" ;;
    rules)             adapter_codex_rulefile ;;
    *)                 echo "" ;;
  esac
}
