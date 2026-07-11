# Claude Code target

Arche installs into your Claude Code configuration under `~/.claude/`.

| Asset | Destination |
|-------|-------------|
| skills | `~/.claude/skills/<id>/` |
| commands | `~/.claude/commands/<id>.md` |
| agents | `~/.claude/agents/<id>.md` |
| prompts | `~/.claude/prompts/<id>.md` |
| scripts | `~/.local/bin/<id>` (chmod +x) |
| rules | managed block inside `~/.claude/CLAUDE.md` |

Rules are written into a marked, idempotent region of `CLAUDE.md`; the file is backed up first and your own content is left untouched.
