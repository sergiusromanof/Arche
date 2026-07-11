#!/usr/bin/env bash
# Claude Code adapter — where each asset type installs under ~/.claude.

adapter_claude_root() { echo "${ARCHE_TARGET_DIR:-$HOME/.claude}"; }

adapter_claude_supports() {
  case "$1" in skills|commands|agents|prompts|scripts|rules) return 0 ;; *) return 1 ;; esac
}

adapter_claude_rulefile() { echo "$(adapter_claude_root)/CLAUDE.md"; }

adapter_claude_dest() {
  local type="$1" id="$2" root; root="$(adapter_claude_root)"
  case "$type" in
    skills)   echo "$root/skills/$id" ;;
    commands) echo "$root/commands/$id.md" ;;
    agents)   echo "$root/agents/$id.md" ;;
    prompts)  echo "$root/prompts/$id.md" ;;
    scripts)  echo "$HOME/.local/bin/$id" ;;
    rules)    adapter_claude_rulefile ;;
    *)        echo "" ;;
  esac
}
