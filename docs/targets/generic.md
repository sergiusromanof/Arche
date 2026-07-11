# Generic / local target

A tool-agnostic layout under `~/.config/arche/` that any local model runner or custom setup can point at.

| Asset | Destination |
|-------|-------------|
| skills | `~/.config/arche/skills/<id>/` |
| commands | `~/.config/arche/commands/<id>.md` |
| agents | `~/.config/arche/agents/<id>.md` |
| prompts | `~/.config/arche/prompts/<id>.md` |
| scripts | `~/.local/bin/<id>` (chmod +x) |
| rules | concatenated into `~/.config/arche/RULES.md` |

Use `--dir <path>` to install into a project directory instead of the global config root.
