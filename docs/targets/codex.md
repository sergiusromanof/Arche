# Codex (OpenAI) target

Arche installs into your Codex configuration under `~/.codex/`.

| Asset | Destination |
|-------|-------------|
| skills | `~/.codex/skills/<id>/` |
| prompts | `~/.codex/prompts/<id>.md` |
| commands | `~/.codex/prompts/<id>.md` (mapped to the nearest concept: prompts) |
| scripts | `~/.local/bin/<id>` (chmod +x) |
| rules | managed block inside `~/.codex/AGENTS.md` |

`agents` are not installed for Codex (no direct equivalent); those assets are skipped with a message.
The exact rule-file path lives in the adapter and is easy to adjust if Codex conventions change.
