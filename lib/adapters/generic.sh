#!/usr/bin/env bash
# Generic / local adapter — a tool-agnostic layout under ~/.config/arche.

adapter_generic_root() { echo "${ARCHE_TARGET_DIR:-$ARCHE_CONFIG_DIR}"; }

adapter_generic_supports() {
  case "$1" in skills|scripts|prompts|commands|agents|rules) return 0 ;; *) return 1 ;; esac
}

adapter_generic_rulefile() { echo "$(adapter_generic_root)/RULES.md"; }

adapter_generic_dest() {
  local type="$1" id="$2" root; root="$(adapter_generic_root)"
  case "$type" in
    skills)   echo "$root/skills/$id" ;;
    prompts)  echo "$root/prompts/$id.md" ;;
    commands) echo "$root/commands/$id.md" ;;
    agents)   echo "$root/agents/$id.md" ;;
    scripts)  echo "$HOME/.local/bin/$id" ;;
    rules)    adapter_generic_rulefile ;;
    *)        echo "" ;;
  esac
}
